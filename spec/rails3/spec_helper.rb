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

def create_new_user
  @user = User.new(:username => 'gizmo', :email => "bla@bla.com", :password => 'secret', :password_confirmation => 'secret')
  @user.save!
end

def plugin_set_model_config_property(property, value)
  User.class_eval do
    activate_simple_auth! do |config|
      config.send("#{property}=".to_sym, value)
    end
  end
end

def plugin_set_controller_config_property(property, value)
  ApplicationController.class_eval do
    activate_simple_auth! do |config|
      config.send("#{property}=".to_sym, value)
    end
  end
end
