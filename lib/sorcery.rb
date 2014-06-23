require 'sorcery/version'

module Sorcery
  autoload :Model, 'sorcery/model'
  module Model
    autoload :TemporaryToken, 'sorcery/model/temporary_token'
    module Adapters
      autoload :ActiveRecord, 'sorcery/model/adapters/active_record'
      autoload :Mongoid, 'sorcery/model/adapters/mongoid'
      autoload :MongoMapper, 'sorcery/model/adapters/mongo_mapper'
      autoload :DataMapper, 'sorcery/model/adapters/datamapper'
    end
    module Submodules
      autoload :UserActivation, 'sorcery/model/submodules/user_activation'
      autoload :ResetPassword, 'sorcery/model/submodules/reset_password'
      autoload :RememberMe, 'sorcery/model/submodules/remember_me'
      autoload :ActivityLogging, 'sorcery/model/submodules/activity_logging'
      autoload :BruteForceProtection, 'sorcery/model/submodules/brute_force_protection'
      autoload :External, 'sorcery/model/submodules/external'
    end
  end
  autoload :Controller, 'sorcery/controller'
  module Controller
    module Submodules
      autoload :RememberMe, 'sorcery/controller/submodules/remember_me'
      autoload :SessionTimeout, 'sorcery/controller/submodules/session_timeout'
      autoload :BruteForceProtection, 'sorcery/controller/submodules/brute_force_protection'
      autoload :HttpBasicAuth, 'sorcery/controller/submodules/http_basic_auth'
      autoload :ActivityLogging, 'sorcery/controller/submodules/activity_logging'
      autoload :External, 'sorcery/controller/submodules/external'
    end
  end
  module Protocols
    autoload :Oauth, 'sorcery/protocols/oauth'
    autoload :Oauth2, 'sorcery/protocols/oauth2'
  end
  module CryptoProviders
    autoload :Common, 'sorcery/crypto_providers/common'
    autoload :AES256, 'sorcery/crypto_providers/aes256'
    autoload :BCrypt, 'sorcery/crypto_providers/bcrypt'
    autoload :MD5,    'sorcery/crypto_providers/md5'
    autoload :SHA1,   'sorcery/crypto_providers/sha1'
    autoload :SHA256, 'sorcery/crypto_providers/sha256'
    autoload :SHA512, 'sorcery/crypto_providers/sha512'
  end
  module TestHelpers
    autoload :Internal, 'sorcery/test_helpers/internal'
    module Internal
      autoload :Rails, 'sorcery/test_helpers/internal/rails'
    end
    autoload :Rails, 'sorcery/test_helpers/rails'
    module Rails
      autoload :Controller, 'sorcery/test_helpers/rails/controller'
      autoload :Integration, 'sorcery/test_helpers/rails/integration'
    end

  end

  if defined?(ActiveRecord)
    ActiveRecord::Base.extend Sorcery::Model
    ActiveRecord::Base.send :include, Sorcery::Model::Adapters::ActiveRecord
  end

  if defined?(Mongoid)
    Mongoid::Document::ClassMethods.send :include, Sorcery::Model
    Mongoid::Document::ClassMethods.send :include, Sorcery::Model::Adapters::Mongoid::ClassMethods
    Mongoid::Document.send :include, Sorcery::Model::Adapters::Mongoid::InstanceMethods
  end

  if defined?(MongoMapper)
    MongoMapper::Document.send(:plugin, Sorcery::Model::Adapters::MongoMapper)
  end

  if defined?(DataMapper)
    DataMapper::Model.append_extensions(Sorcery::Model)
    DataMapper::Model.append_inclusions(Sorcery::Model::Adapters::DataMapper)
  end

  require 'sorcery/engine' if defined?(Rails) && Rails::VERSION::MAJOR >= 3
end
