require 'sorcery/version'

module Sorcery

  require 'sorcery/model'

  module Model
    require 'sorcery/model/temporary_token'
    require 'sorcery/model/config'

    module Adapters
    end

    module Submodules
      require 'sorcery/model/submodules/user_activation'
      require 'sorcery/model/submodules/reset_password'
      require 'sorcery/model/submodules/remember_me'
      require 'sorcery/model/submodules/activity_logging'
      require 'sorcery/model/submodules/brute_force_protection'
      require 'sorcery/model/submodules/external'
    end
  end

  require 'sorcery/controller'

  module Controller
    autoload :Config, 'sorcery/controller/config'
    module Submodules
      require 'sorcery/controller/submodules/remember_me'
      require 'sorcery/controller/submodules/session_timeout'
      require 'sorcery/controller/submodules/brute_force_protection'
      require 'sorcery/controller/submodules/http_basic_auth'
      require 'sorcery/controller/submodules/activity_logging'
      require 'sorcery/controller/submodules/external'
    end
  end

  module Protocols
    require 'sorcery/protocols/oauth'
    require 'sorcery/protocols/oauth2'
  end

  module CryptoProviders
    require 'sorcery/crypto_providers/common'
    require 'sorcery/crypto_providers/aes256'
    require 'sorcery/crypto_providers/bcrypt'
    require 'sorcery/crypto_providers/md5'
    require 'sorcery/crypto_providers/sha1'
    require 'sorcery/crypto_providers/sha256'
    require 'sorcery/crypto_providers/sha512'
  end

  module TestHelpers
    require 'sorcery/test_helpers/internal'

    module Rails
      require 'sorcery/test_helpers/rails/controller'
      require 'sorcery/test_helpers/rails/integration'
    end

    module Internal
      require 'sorcery/test_helpers/internal/rails'
    end

  end

  if defined?(ActiveRecord)
    require 'sorcery/model/adapters/active_record'
    ActiveRecord::Base.extend Sorcery::Model
    ActiveRecord::Base.send :include, Sorcery::Model::Adapters::ActiveRecord
  end

  if defined?(Mongoid)
    require 'sorcery/model/adapters/mongoid'
    Mongoid::Document::ClassMethods.send :include, Sorcery::Model
    Mongoid::Document::ClassMethods.send :include, Sorcery::Model::Adapters::Mongoid::ClassMethods
    Mongoid::Document.send :include, Sorcery::Model::Adapters::Mongoid::InstanceMethods
  end

  if defined?(MongoMapper)
    require 'sorcery/model/adapters/mongo_mapper'
    MongoMapper::Document.send(:plugin, Sorcery::Model::Adapters::MongoMapper)
  end

  if defined?(DataMapper)
    require 'sorcery/model/adapters/datamapper'
    DataMapper::Model.append_extensions(Sorcery::Model)
    DataMapper::Model.append_inclusions(Sorcery::Model::Adapters::DataMapper)
  end

  require 'sorcery/engine' if defined?(Rails) && Rails::VERSION::MAJOR >= 3
end
