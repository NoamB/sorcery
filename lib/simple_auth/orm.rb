module SimpleAuth
  module ORM
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
      end
    end
    
    module ClassMethods
      def activate_simple_auth!
        yield Config if block_given?
        
        if Config.encryption_algorithm == :aes256
          CryptoProviders::AES256.key = Config.encryption_key
        end
        
        self.class_eval do
          #include InstanceMethods
          
          if defined?(ActiveRecord) && self.ancestors.include?(ActiveRecord::Base)
            require 'simple_auth/orm/plugins/active_record'
            include Plugins::ActiveRecord
          end
          
          def self.authentic?(username, password)
            user = where("#{Config.username_attribute_name} = ?", username).first
            user if user && (user.send(Config.crypted_password_attribute_name) == encrypt(password))
          end
                    
          def self.encrypt(*tokens)
            case Config.encryption_algorithm
            when :none then tokens.first
            when :md5  then CryptoProviders::MD5.encrypt(*tokens)
            when :sha1 then CryptoProviders::SHA1.encrypt(*tokens)
            when :sha256 then CryptoProviders::SHA256.encrypt(*tokens)
            when :sha512 then CryptoProviders::SHA512.encrypt(*tokens)
            when :aes256 then CryptoProviders::AES256.encrypt(*tokens)
            when :bcrypt then CryptoProviders::BCrypt.encrypt(*tokens)
            when :custom then Config.custom_encryption_provider.encrypt(*tokens)
            end
          end
        end
      end
    end
    
    module InstanceMethods
    end
    
    module Config
      class << self
        attr_accessor :username_attribute_name, 
                      :password_attribute_name,
                      :confirm_password,
                      :password_confirmation_attribute_name,
                      :crypted_password_attribute_name,
                      :encryption_algorithm,
                      :custom_encryption_provider,
                      :encryption_key
        
        def reset_to_defaults!
          @username_attribute_name              = :username
          @password_attribute_name              = :password
          @confirm_password                     = true
          @password_confirmation_attribute_name = :password_confirmation
          @crypted_password_attribute_name      = :crypted_password
          @encryption_algorithm                 = :sha256
          @custom_encryption_provider           = nil
          @encryption_key                       = nil
        end
      
      end
      reset_to_defaults!
    end
  end
end