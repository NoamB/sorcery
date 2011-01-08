module SimpleAuth
  module Model
    def self.included(klass)
      klass.class_eval do
        class << self
          def activate_simple_auth!(*submodules)
            @simple_auth_config = Config.new
            @simple_auth_config.submodules = submodules
            self.class_eval do
              submodules.each do |mod|
                include Submodules.const_get(mod.to_s.split("_").map {|p| p.capitalize}.join(""))
              end
            end

            yield @config if block_given?

            self.class_eval do
              include Adapters::ActiveRecord if defined?(ActiveRecord) && self.ancestors.include?(ActiveRecord::Base)
              extend ClassMethods
              include InstanceMethods
            end
          end
        end
      end
    end
    
    module InstanceMethods
      def simple_auth_config
        self.class.simple_auth_config
      end
    end
    
    module ClassMethods
      def simple_auth_config
        @simple_auth_config
      end
      
      def authentic?(username, password)
        user = where("#{@simple_auth_config.username_attribute_name} = ?", username).first
        user if user && (user.send(@simple_auth_config.crypted_password_attribute_name) == encrypt(password))
      end
                
      def encrypt(*tokens)
        case @simple_auth_config.encryption_algorithm
        when :none then tokens.first
        when :md5  then CryptoProviders::MD5.encrypt(*tokens)
        when :sha1 then CryptoProviders::SHA1.encrypt(*tokens)
        when :sha256 then CryptoProviders::SHA256.encrypt(*tokens)
        when :sha512 then CryptoProviders::SHA512.encrypt(*tokens)
        when :aes256 then CryptoProviders::AES256.encrypt(*tokens)
        when :bcrypt then CryptoProviders::BCrypt.encrypt(*tokens)
        when :custom then @simple_auth_config.custom_encryption_provider.encrypt(*tokens)
        end
      end
      
    end

    # Each class which calls 'activate_simple_auth!' receives an instance of this class.
    # This enables two different classes to use this plugin with different configurations.
    class Config
      attr_accessor :submodules,
                    :username_attribute_name, 
                    :password_attribute_name,
                    :crypted_password_attribute_name,
                    :custom_encryption_provider
                            
      attr_reader   :encryption_algorithm,
                    :encryption_key
      
      def initialize
        @defaults = {
          :@username_attribute_name              => :username,
          :@password_attribute_name              => :password,
          :@crypted_password_attribute_name      => :crypted_password,
          :@encryption_algorithm                 => :sha256,
          :@custom_encryption_provider           => nil,
          :@encryption_key                       => nil
        }
        reset!
      end     
            
      def encryption_algorithm=(algo)
        @encryption_algorithm = algo
        set_encryption_key_to_provider
      end
      
      def encryption_key=(key)
        @encryption_key = key
        set_encryption_key_to_provider
      end
      
      def set_encryption_key_to_provider
        CryptoProviders::AES256.key = @encryption_key if @encryption_algorithm == :aes256
      end
      
      def reset!
        @defaults.each do |k,v|
          instance_variable_set(k,v)
        end       
      end
    end
    
  end
end