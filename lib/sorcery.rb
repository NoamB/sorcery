module Sorcery
  autoload :Model, 'sorcery/model'
  module Model
    module Submodules
      autoload :UserActivation, 'sorcery/model/submodules/user_activation'
      autoload :PasswordReset, 'sorcery/model/submodules/password_reset'
      autoload :RememberMe, 'sorcery/model/submodules/remember_me'
    end
  end
  autoload :Controller, 'sorcery/controller'
  module Controller
    module Submodules
      autoload :RememberMe, 'sorcery/controller/submodules/remember_me'
      autoload :SessionTimeout, 'sorcery/controller/submodules/session_timeout'
      autoload :BruteForceProtection, 'sorcery/controller/submodules/brute_force_protection'
      autoload :HttpBasicAuth, 'sorcery/controller/submodules/http_basic_auth'
    end
  end
  module CryptoProviders
    autoload :AES256, 'sorcery/crypto_providers/aes256'
    autoload :BCrypt, 'sorcery/crypto_providers/bcrypt'
    autoload :MD5,    'sorcery/crypto_providers/md5'
    autoload :SHA1,   'sorcery/crypto_providers/sha1'
    autoload :SHA256, 'sorcery/crypto_providers/sha256'
    autoload :SHA512, 'sorcery/crypto_providers/sha512'
  end
  
  require 'sorcery/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
end