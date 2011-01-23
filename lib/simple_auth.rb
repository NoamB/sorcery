module SimpleAuth
  autoload :Model, 'simple_auth/model'
  module Model
    module Submodules
      autoload :PasswordConfirmation, 'simple_auth/model/submodules/password_confirmation'
      autoload :PasswordEncryption, 'simple_auth/model/submodules/password_encryption'
      autoload :UserActivation, 'simple_auth/model/submodules/user_activation'
      autoload :PasswordReset, 'simple_auth/model/submodules/password_reset'
      autoload :RememberMe, 'simple_auth/model/submodules/remember_me'
    end
    module Adapters
      autoload :ActiveRecord, 'simple_auth/model/adapters/active_record'
    end
  end
  autoload :Controller, 'simple_auth/controller'
  module CryptoProviders
    autoload :AES256, 'simple_auth/crypto_providers/aes256'
    autoload :BCrypt, 'simple_auth/crypto_providers/bcrypt'
    autoload :MD5,    'simple_auth/crypto_providers/md5'
    autoload :SHA1,   'simple_auth/crypto_providers/sha1'
    autoload :SHA256, 'simple_auth/crypto_providers/sha256'
    autoload :SHA512, 'simple_auth/crypto_providers/sha512'
  end
  
  require 'simple_auth/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
end