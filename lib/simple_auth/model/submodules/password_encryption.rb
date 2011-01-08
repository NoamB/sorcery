module SimpleAuth
  module Model
    module Submodules
      module PasswordEncryption
        def self.included(base)
          base.extend ClassMethods
          
          base.simple_auth_config.class_eval do
            attr_accessor :crypted_password_attribute_name,
                          :custom_encryption_provider

            attr_reader   :encryption_algorithm,
                          :encryption_key
                          
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
          end
          
          base.simple_auth_config.instance_eval do
            @defaults.merge!(:@crypted_password_attribute_name      => :crypted_password,
                             :@encryption_algorithm                 => :sha256,
                             :@custom_encryption_provider           => nil,
                             :@encryption_key                       => nil)
            reset!
          end
        end
        
        module ClassMethods
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
      end
    end
  end
end