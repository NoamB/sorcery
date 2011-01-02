require 'simple_auth'
require 'rails'

module SimpleAuth  
  class Engine < Rails::Engine
    initializer "extend ORM with simple_auth" do |app|
      ActiveRecord::Base.send(:include, SimpleAuth::ORM) if defined?(ActiveRecord)
    end
    
    initializer "extend Controller with simple_auth" do |app|
      ActionController::Base.send(:include, SimpleAuth::Controller)
      ActionController::Base.activate_simple_auth!
    end
  end
end