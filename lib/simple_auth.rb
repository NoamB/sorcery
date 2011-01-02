module SimpleAuth
  # TODO: autoloads here?
  
  # TODO: central config
  
  
  require 'simple_auth/crypto_providers'
  require 'simple_auth/orm'
  require 'simple_auth/controller'
  require 'simple_auth/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
end