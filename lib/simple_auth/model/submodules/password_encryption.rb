module SimpleAuth
  module Model
    module Submodules
      module PasswordEncryption
        def self.included(base)
          base.extend ClassMethods
          
          base.simple_auth_config.class_eval do
            attr_accessor :crypted_password_attribute_name,
                          :salt_join_token,
                          :salt_attribute_name,
                          :stretches,
                          :encryption_key

            attr_reader   :encryption_provider, # only getter
                          :custom_encryption_provider,
                          :encryption_algorithm
                          
                    
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
            
            def custom_encryption_provider=(provider)
              @custom_encryption_provider = @encryption_provider = provider
            end
          end
          
          base.simple_auth_config.instance_eval do
            @defaults.merge!(:@crypted_password_attribute_name      => :crypted_password,
                             :@encryption_algorithm                 => :sha256,
                             :@custom_encryption_provider           => nil,
                             :@encryption_key                       => nil,
                             :@salt_join_token                      => "",
                             :@salt_attribute_name                  => :salt,
                             :@stretches                            => nil)
            reset!
          end
          
          #base.send(:include, InstanceMethods)
        end
        
        module InstanceMethods
          
        end
        
        module ClassMethods
          def authenticate(username, password)
            user = where("#{@simple_auth_config.username_attribute_name} = ?", username).first
            salt = user.send(@simple_auth_config.salt_attribute_name) if !@simple_auth_config.salt_attribute_name.nil?
            user if user && (user.send(@simple_auth_config.crypted_password_attribute_name)) == encrypt(password,salt)
          end
          
          def encrypt(*tokens)
            return tokens.first if @simple_auth_config.encryption_provider.nil?
            
            @simple_auth_config.encryption_provider.stretches = @simple_auth_config.stretches if @simple_auth_config.encryption_provider.respond_to?(:stretches) && @simple_auth_config.stretches
            @simple_auth_config.encryption_provider.join_token = @simple_auth_config.salt_join_token if @simple_auth_config.encryption_provider.respond_to?(:join_token) && @simple_auth_config.salt_join_token
            CryptoProviders::AES256.key = @simple_auth_config.encryption_key if @simple_auth_config.encryption_algorithm == :aes256
            @simple_auth_config.encryption_provider.encrypt(*tokens)
          end
        end
      end
    end
  end
end