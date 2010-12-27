require 'digest/md5'
require 'active_support'

module SimpleAuth
  module ORM
    extend ::ActiveSupport::Concern
    
    module ClassMethods
      def activate_simple_auth!
        yield Config if block_given?
        
        if Config.encryption_algorithm == :aes256
          CryptoProviders::AES256.key = Config.encryption_key
        end
        
        self.class_eval do
          def self.authentic?(username, password)
            where("#{Config.username_attribute_name} = ? AND #{Config.crypted_password_attribute_name} = ?", username, encrypt(password)).first
          end
                    
          def self.encrypt(*tokens)
            case Config.encryption_algorithm
            when :none then tokens.first
            when :md5  then CryptoProviders::MD5.encrypt(*tokens)
            when :sha1 then CryptoProviders::SHA1.encrypt(*tokens)
            when :sha256 then CryptoProviders::SHA256.encrypt(*tokens)
            when :sha512 then CryptoProviders::SHA512.encrypt(*tokens)
            when :aes256 then CryptoProviders::AES256.encrypt(*tokens)
            when :custom then Config.custom_encryption_provider.encrypt(*tokens)
            end
          end
        end
      end
    end
    
    module Config
      class << self
        attr_accessor :username_attribute_name, 
                      :crypted_password_attribute_name,
                      :encryption_algorithm,
                      :custom_encryption_provider,
                      :encryption_key
        
        def reset_to_defaults!
          @username_attribute_name         = :username
          @crypted_password_attribute_name = :crypted_password
          @encryption_algorithm            = :md5
          @custom_encryption_provider      = nil
          @encryption_key                  = nil
        end
      
      end
      reset_to_defaults!
    end
  end
end