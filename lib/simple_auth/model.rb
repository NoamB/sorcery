module SimpleAuth
  module Model
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
      end
    end
    
    module ClassMethods
      def activate_simple_auth!(*submodules)
        Config.submodules = submodules
        self.class_eval do
          submodules.each do |mod|
            include Submodules.const_get(mod.to_s.split("_").map {|p| p.capitalize}.join(""))
            #include Submodules::PasswordConfirmation
          end
        end
        
        yield Config if block_given?
        
        self.class_eval do
          include Adapters::ActiveRecord if defined?(ActiveRecord) && self.ancestors.include?(ActiveRecord::Base)
          
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
          
          private
          
          # useful for tests
          def self.simple_auth_config
            Config
          end
        end
      end
    end
    
    module Config
      class << self
        attr_accessor :submodules,
                      :username_attribute_name, 
                      :password_attribute_name,
                      :crypted_password_attribute_name,
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
        
        DEFAULT_VALUES = {
          :@username_attribute_name              => :username,
          :@password_attribute_name              => :password,
          :@crypted_password_attribute_name      => :crypted_password,
          :@encryption_algorithm                 => :sha256,
          :@custom_encryption_provider           => nil,
          :@encryption_key                       => nil
        }
        
        def reset!
          DEFAULT_VALUES.each do |k,v|
            instance_variable_set(k,v)
          end       
        end
      
      end
      reset!
    end
  end
end