module Sorcery
  # This module handles all plugin operations which are related to the Model layer in the MVC pattern.
  # It should be included into the ORM base class.
  # In the case of Rails this is usually ActiveRecord (actually, in that case, the plugin does this automatically).
  #
  # When included it defines a single method: 'activate_sorcery!' which when called adds the other capabilities to the class.
  # This method is also the place to configure the plugin in the Model layer.
  module Model
    def self.included(klass)
      klass.class_eval do
        class << self
          def activate_sorcery!
            @sorcery_config = Config.new
            self.class_eval do
              extend ClassMethods # included here, before submodules, so they can be overriden by them.
              include InstanceMethods
              ::Sorcery::Controller::Config.user_class = self
              @sorcery_config.submodules = ::Sorcery::Controller::Config.submodules
              @sorcery_config.submodules.each do |mod|
                begin
                  include Submodules.const_get(mod.to_s.split("_").map {|p| p.capitalize}.join("")) 
                rescue NameError
                  # don't stop on a missing submodule.
                end
              end
            end
            
            yield @sorcery_config if block_given?
            
            self.class_eval do
              attr_accessor @sorcery_config.password_attribute_name
              attr_protected @sorcery_config.crypted_password_attribute_name, @sorcery_config.salt_attribute_name
              before_save :encrypt_password, :if => Proc.new { |record| record.send(sorcery_config.password_attribute_name).present? }
              after_save :clear_virtual_password, :if => Proc.new { |record| record.send(sorcery_config.password_attribute_name).present? }
            end
            @sorcery_config.after_config.each { |c| send(c) }
          end
        end
      end
    end
    
    module ClassMethods
      # Returns the class instance variable for configuration, when called by the class itself.
      def sorcery_config
        @sorcery_config
      end
      
      # The default authentication method.
      # Takes a username and password,
      # Finds the user by the username and compares the user's password to the one supplied to the method.
      # returns the user if success, nil otherwise.
      def authenticate(*credentials)
        raise ArgumentError, "at least 2 arguments required" if credentials.size < 2
        user = where("#{@sorcery_config.username_attribute_name} = ?", credentials[0]).first
        salt = user.send(@sorcery_config.salt_attribute_name) if user && !@sorcery_config.salt_attribute_name.nil?
        user if user && @sorcery_config.before_authenticate.all? {|c| user.send(c)} && (user.send(@sorcery_config.crypted_password_attribute_name)) == encrypt(credentials[1],salt)
      end
      
      def encrypt(*tokens)
        return tokens.first if @sorcery_config.encryption_provider.nil?
        
        @sorcery_config.encryption_provider.stretches = @sorcery_config.stretches if @sorcery_config.encryption_provider.respond_to?(:stretches) && @sorcery_config.stretches
        @sorcery_config.encryption_provider.join_token = @sorcery_config.salt_join_token if @sorcery_config.encryption_provider.respond_to?(:join_token) && @sorcery_config.salt_join_token
        CryptoProviders::AES256.key = @sorcery_config.encryption_key if @sorcery_config.encryption_algorithm == :aes256
        @sorcery_config.encryption_provider.encrypt(*tokens)
      end
    end
    
    module InstanceMethods
      # Returns the class instance variable for configuration, when called by an instance.
      def sorcery_config
        self.class.sorcery_config
      end
      
      protected
      
      # creates new salt and saves it.
      # encrypts password with salt and save it.
      def encrypt_password
        config = sorcery_config
        self.send(:"#{config.salt_attribute_name}=", generate_random_code) if !config.salt_attribute_name.nil?
        self.send(:"#{config.crypted_password_attribute_name}=", self.class.encrypt(self.send(config.password_attribute_name),salt))
      end

      def clear_virtual_password
        config = sorcery_config
        self.send(:"#{config.password_attribute_name}=", nil)
      end
      
      # calls the requested email method on the configured mailer
      # supports both the ActionMailer 3 way of calling, and the plain old Ruby object way.
      def generic_send_email(method)
        config = sorcery_config
        mail = config.sorcery_mailer.send(config.send(method),self)
        if defined?(ActionMailer) and config.sorcery_mailer.superclass == ActionMailer::Base
          mail.deliver
        end
      end
      
      # Random code, used for salt and temporary tokens.
      def generate_random_code
        return Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      end
    end

    # Each class which calls 'activate_sorcery!' receives an instance of this class.
    # Every submodule which gets loaded may add accessors to this class so that all options will be configured from a single place.
    class Config
      attr_accessor :submodules,
                    :username_attribute_name, 
                    :password_attribute_name,
                    :email_attribute_name,
                    :crypted_password_attribute_name,
                    :salt_join_token,
                    :salt_attribute_name,
                    :stretches,
                    :encryption_key,
                    :before_authenticate,
                    :after_config
                    
      attr_reader   :encryption_provider,
                    :custom_encryption_provider,
                    :encryption_algorithm                            

      def initialize
        @defaults = {
          :@submodules                           => [],
          :@username_attribute_name              => :username,
          :@password_attribute_name              => :password,
          :@email_attribute_name                 => :email,
          :@crypted_password_attribute_name      => :crypted_password,
          :@encryption_algorithm                 => :sha256,
          :@encryption_provider                  => CryptoProviders::SHA256,
          :@custom_encryption_provider           => nil,
          :@encryption_key                       => nil,
          :@salt_join_token                      => "",
          :@salt_attribute_name                  => :salt,
          :@stretches                            => nil,
          :@before_authenticate                  => [],
          :@after_config                         => []
        }
        reset!
      end     
           
      # Resets all configuration options to their default values.
      def reset!
        @defaults.each do |k,v|
          instance_variable_set(k,v)
        end       
      end
      
      def custom_encryption_provider=(provider)
        @custom_encryption_provider = @encryption_provider = provider
      end
      
      def encryption_algorithm=(algo)
        @encryption_algorithm = algo
        @encryption_provider = case @encryption_algorithm
        when :none   then nil
        when :md5    then CryptoProviders::MD5
        when :sha1   then CryptoProviders::SHA1
        when :sha256 then CryptoProviders::SHA256
        when :sha512 then CryptoProviders::SHA512
        when :aes256 then CryptoProviders::AES256
        when :bcrypt then CryptoProviders::BCrypt
        when :custom then @custom_encryption_provider
        end
      end
      
    end
    
  end
end