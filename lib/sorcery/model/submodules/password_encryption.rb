module Sorcery
  module Model
    module Submodules
      module PasswordEncryption
        def self.included(base)
          base.extend ClassMethods
          
          base.sorcery_config.class_eval do
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
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@crypted_password_attribute_name      => :crypted_password,
                             :@encryption_algorithm                 => :sha256,
                             :@custom_encryption_provider           => nil,
                             :@encryption_key                       => nil,
                             :@salt_join_token                      => "",
                             :@salt_attribute_name                  => :salt,
                             :@stretches                            => nil)
            reset!
          end
          
          base.class_eval do
            attr_accessor @sorcery_config.password_attribute_name
            before_save :encrypt_password, :if => Proc.new {|record| record.new_record? || record.send(sorcery_config.password_attribute_name)}
            after_save :clear_virtual_password, :if => Proc.new {|record| record.valid? && record.send(sorcery_config.password_attribute_name)}
          end
          base.send(:include, InstanceMethods)
        end
        
        module InstanceMethods

          protected
          
          def encrypt_password
            config = sorcery_config
            salt = ""
            if !config.salt_attribute_name.nil?
              salt = Time.now.to_s
              self.send(:"#{config.salt_attribute_name}=", salt)
            end
            self.send(:"#{config.crypted_password_attribute_name}=", self.class.encrypt(self.send(config.password_attribute_name),salt))
          end

          def clear_virtual_password
            config = sorcery_config
            self.send(:"#{config.password_attribute_name}=", nil)
          end
        end
        
        module ClassMethods
          def authenticate(username, password)
            user = where("#{@sorcery_config.username_attribute_name} = ?", username).first
            if user
              salt = user.send(@sorcery_config.salt_attribute_name) if !@sorcery_config.salt_attribute_name.nil?
            end
            user if user && @sorcery_config.before_authenticate_callbacks.all? {|proc| proc.call(user, @sorcery_config)} && (user.send(@sorcery_config.crypted_password_attribute_name)) == encrypt(password,salt)
          end
          
          def encrypt(*tokens)
            return tokens.first if @sorcery_config.encryption_provider.nil?
            
            @sorcery_config.encryption_provider.stretches = @sorcery_config.stretches if @sorcery_config.encryption_provider.respond_to?(:stretches) && @sorcery_config.stretches
            @sorcery_config.encryption_provider.join_token = @sorcery_config.salt_join_token if @sorcery_config.encryption_provider.respond_to?(:join_token) && @sorcery_config.salt_join_token
            CryptoProviders::AES256.key = @sorcery_config.encryption_key if @sorcery_config.encryption_algorithm == :aes256
            @sorcery_config.encryption_provider.encrypt(*tokens)
          end
        end
      end
    end
  end
end