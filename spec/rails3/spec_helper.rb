$: << File.join(File.dirname(__FILE__), '..', '..', 'lib' )

require 'simplecov'
SimpleCov.root File.join(File.dirname(__FILE__), "app_root" )
SimpleCov.start do
  add_filter "/config/"
  
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Libraries', 'lib'
  add_group 'Plugins', 'vendor/plugins'
  add_group 'Migrations', 'db/migrate'
end

# Set the default environment to sqlite3's in_memory database
ENV['RAILS_ENV'] ||= 'in_memory'
ENV['RAILS_ROOT'] = 'app_root'

# Load the Rails environment and testing framework
require "#{File.dirname(__FILE__)}/app_root/config/environment"
#require "#{File.dirname(__FILE__)}/../../init" # for plugins
require 'rspec/rails'

# Undo changes to RAILS_ENV
silence_warnings {RAILS_ENV = ENV['RAILS_ENV']}

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.include RSpec::Rails::ControllerExampleGroup, :example_group => { :file_path => /_controller_spec.rb$/ }#:file_path => /\bspec[\\\/]controllers[\\\/]/ }
end

#----------------------------------------------------------------
require File.join(File.dirname(__FILE__), 'app_root','app','models','user')

class TestUser < ActiveRecord::Base
  activate_simple_auth!
end

class TestMailer < ActionMailer::Base
  
end

module SimpleAuth
  module Model
    module Submodules
      module TestSubmodule
        def my_instance_method
        end
      end
    end
  end
end

def create_new_user
  user_attributes_hash = {:username => 'gizmo', :email => "bla@bla.com", :password => 'secret'}
  user_attributes_hash.merge!(:password_confirmation => 'secret') if User.simple_auth_config.submodules.include?(:password_confirmation)
  @user = User.new(user_attributes_hash)
  @user.save!
end

def plugin_model_configure(submodules = [], options = {})
  ::SimpleAuth::Controller::Config.submodules = submodules

  reload_user_class
  
  User.activate_simple_auth! do |config|
    options.each do |property,value|
      config.send(:"#{property}=", value)
    end
  end
end

def plugin_set_model_config_property(property, *values)
  User.class_eval do
    simple_auth_config.send(:"#{property}=", *values)
  end
end

def plugin_set_controller_config_property(property, value)
  ApplicationController.class_eval do
    ::SimpleAuth::Controller::Config.send(:"#{property}=", value)
  end
end

def plugin_controller_configure(submodules = [], options = {})
  ApplicationController.class_eval do
    activate_simple_auth!(*submodules) do |config|
      options.each do |property,value|
        config.send(:"#{property}=", value)
      end
    end
  end
end

private

def reload_user_class
  Object.send(:remove_const,:User)
  load 'user.rb'
end