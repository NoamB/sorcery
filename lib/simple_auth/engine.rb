require 'simple_auth'
require 'rails'
require 'active_record'

module SimpleAuth  
  class Engine < Rails::Engine
    initializer "extend ORM with simple_auth" do |app|
      ActiveRecord::Base.send(:include, SimpleAuth::ORM)
    end
  end
end