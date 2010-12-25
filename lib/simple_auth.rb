module SimpleAuth
  require 'simple_auth/orm'
  require 'simple_auth/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
end