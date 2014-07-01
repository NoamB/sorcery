# Each class which calls 'activate_sorcery!' receives an instance of this class.
# Every submodule which gets loaded may add accessors to this class so that all
# options will be configured from a single place.
module Sorcery
  module Model
    class Config

      attr_accessor :username_attribute_names,           # change default username attribute, for example, to use :email
                                                        # as the login.

                    :password_attribute_name,           # change *virtual* password attribute, the one which is used
                                                        # until an encrypted one is generated.

                    :email_attribute_name,              # change default email attribute.

                    :downcase_username_before_authenticating, # downcase the username before trying to authenticate, default is false

                    :crypted_password_attribute_name,   # change default crypted_password attribute.
                    :salt_join_token,                   # what pattern to use to join the password with the salt
                    :salt_attribute_name,               # change default salt attribute.
                    :stretches,                         # how many times to apply encryption to the password.
                    :encryption_key,                    # encryption key used to encrypt reversible encryptions such as
                                                        # AES256.

                    :subclasses_inherit_config,         # make this configuration inheritable for subclasses. Useful for
                                                        # ActiveRecord's STI.

                    :submodules,                        # configured in config/application.rb
                    :before_authenticate,               # an array of method names to call before authentication
                                                        # completes. used internally.

                    :after_config                       # an array of method names to call after configuration by user.
                                                        # used internally.

      attr_reader   :encryption_provider,               # change default encryption_provider.
                    :custom_encryption_provider,        # use an external encryption class.
                    :encryption_algorithm               # encryption algorithm name. See 'encryption_algorithm=' below
                                                        # for available options.

      def initialize
        @defaults = {
          :@submodules                           => [],
          :@username_attribute_names              => [:email],
          :@password_attribute_name              => :password,
          :@downcase_username_before_authenticating => false,
          :@email_attribute_name                 => :email,
          :@crypted_password_attribute_name      => :crypted_password,
          :@encryption_algorithm                 => :bcrypt,
          :@encryption_provider                  => CryptoProviders::BCrypt,
          :@custom_encryption_provider           => nil,
          :@encryption_key                       => nil,
          :@salt_join_token                      => "",
          :@salt_attribute_name                  => :salt,
          :@stretches                            => nil,
          :@subclasses_inherit_config            => false,
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

      def username_attribute_names=(fields)
        @username_attribute_names = fields.kind_of?(Array) ? fields : [fields]
      end

      def custom_encryption_provider=(provider)
        @custom_encryption_provider = @encryption_provider = provider
      end

      def encryption_algorithm=(algo)
        @encryption_algorithm = algo
        @encryption_provider = case @encryption_algorithm.to_sym
        when :none   then nil
        when :md5    then CryptoProviders::MD5
        when :sha1   then CryptoProviders::SHA1
        when :sha256 then CryptoProviders::SHA256
        when :sha512 then CryptoProviders::SHA512
        when :aes256 then CryptoProviders::AES256
        when :bcrypt then CryptoProviders::BCrypt
        when :custom then @custom_encryption_provider
        else raise ArgumentError.new("Encryption algorithm supplied, #{algo}, is invalid")
        end
      end

    end

  end
end

