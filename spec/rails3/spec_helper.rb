$: << File.join(File.dirname(__FILE__), "/../lib" )

# Set the default environment to sqlite3's in_memory database
ENV['RAILS_ENV'] ||= 'in_memory'
ENV['RAILS_ROOT'] = 'app_root'

# Load the Rails environment and testing framework
require "#{File.dirname(__FILE__)}/app_root/config/environment"
#require "#{File.dirname(__FILE__)}/../../init" # for plugins
require 'rspec/rails'

# Undo changes to RAILS_ENV
silence_warnings {RAILS_ENV = ENV['RAILS_ENV']}

# Run the migrations
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.include RSpec::Rails::ControllerExampleGroup, :example_group => { :file_path => /_controller_spec.rb$/ }#:file_path => /\bspec[\\\/]controllers[\\\/]/ }
end

#----------------------------------------------------------------

class TestUser < ActiveRecord::Base
  activate_simple_auth!
end

def create_new_user
  user_attributes_hash = {:username => 'gizmo', :email => "bla@bla.com", :password => 'secret'}
  user_attributes_hash.merge!(:password_confirmation => 'secret') if User.simple_auth_config.submodules.include?(:password_confirmation)
  @user = User.new(user_attributes_hash)
  @user.save!
end

def plugin_model_configure(submodules = [], options = {})
  reload_user_class
  
  User.activate_simple_auth!(*submodules) do |config|
    options.each do |k,v|
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
    activate_simple_auth! do |config|
      config.send(:"#{property}=", value)
    end
  end
end

private

def reload_user_class
  Object.send(:remove_const,:User)
  load 'user.rb'
end
