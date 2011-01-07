module SimpleAuth
  module Model
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end
    
    module InstanceMethods
      
    end
    
    module ClassMethods
      def simple_auth_config
        @config
      end
      
      def activate_simple_auth!(*submodules)
        @config = Config.new
        @config.submodules = submodules
        self.class_eval do
          submodules.each do |mod|
            include Submodules.const_get(mod.to_s.split("_").map {|p| p.capitalize}.join(""))
            #include Submodules::PasswordConfirmation
          end
        end
        
        yield @config if block_given?
        
        self.class_eval do
          include Adapters::ActiveRecord if defined?(ActiveRecord) && self.ancestors.include?(ActiveRecord::Base)
          
          def self.authentic?(username, password)
            user = where("#{@config.username_attribute_name} = ?", username).first
            user if user && (user.send(@config.crypted_password_attribute_name) == encrypt(password))
          end
                    
          def self.encrypt(*tokens)
            case @config.encryption_algorithm
            when :none then tokens.first
            when :md5  then CryptoProviders::MD5.encrypt(*tokens)
            when :sha1 then CryptoProviders::SHA1.encrypt(*tokens)
            when :sha256 then CryptoProviders::SHA256.encrypt(*tokens)
            when :sha512 then CryptoProviders::SHA512.encrypt(*tokens)
            when :aes256 then CryptoProviders::AES256.encrypt(*tokens)
            when :bcrypt then CryptoProviders::BCrypt.encrypt(*tokens)
            when :custom then @config.custom_encryption_provider.encrypt(*tokens)
            end
          end
          
          private
          
          # useful for tests
          def self.simple_auth_config
            @config
          end
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