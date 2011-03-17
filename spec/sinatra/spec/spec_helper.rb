require File.join(File.dirname(__FILE__), '..', 'myapp.rb')

require 'sinatra'
require 'rack/test'
require 'rspec'

set :environment, :test

Rspec.configure do |config|
  #config.before(:each) { DataMapper.auto_migrate! }
end

class TestUser < ActiveRecord::Base
  activate_sorcery!
end

class TestMailer < ActionMailer::Base

end

def sorcery_reload!(submodules = [], options = {})
  reload_user_class

  # return to no-module configuration
  ::Sorcery::Controller::Config.init!
  ::Sorcery::Controller::Config.reset!

  # configure
  ::Sorcery::Controller::Config.submodules = submodules
  ::Sorcery::Controller::Config.user_class = nil

  User.activate_sorcery! do |config|
    options.each do |property,value|
      config.send(:"#{property}=", value)
    end
  end
end

def sorcery_model_property_set(property, *values)
  User.class_eval do
    sorcery_config.send(:"#{property}=", *values)
  end
end

def sorcery_controller_property_set(property, value)
  activate_sorcery! do |config|
    config.send(:"#{property}=", value)
  end
end

def sorcery_controller_oauth_property_set(provider, property, value)
  activate_sorcery! do |config|
    config.send(provider).send(:"#{property}=", value)
  end
end

private

# reload user class between specs
# so it will be possible to test the different submodules in isolation
def reload_user_class
  Object.send(:remove_const,:User)
  load File.join(File.dirname(__FILE__),'../user.rb')
end