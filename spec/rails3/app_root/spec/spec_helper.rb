$: << File.join(File.dirname(__FILE__), '..', '..', 'lib' )

# require 'simplecov'
# SimpleCov.root File.join(File.dirname(__FILE__), "app_root" )
# SimpleCov.start do
#   add_filter "/config/"
#   
#   add_group 'Controllers', 'app/controllers'
#   add_group 'Models', 'app/models'
#   add_group 'Helpers', 'app/helpers'
#   add_group 'Libraries', 'lib'
#   add_group 'Plugins', 'vendor/plugins'
#   add_group 'Migrations', 'db/migrate'
# end

require 'spork'

Spork.prefork do
  # Set the default environment to sqlite3's in_memory database
  ENV['RAILS_ENV'] ||= 'in_memory'
  ENV['RAILS_ROOT'] = 'app_root'
  
  # Load the Rails environment and testing framework
  require "#{File.dirname(__FILE__)}/../config/environment"
  #require "#{File.dirname(__FILE__)}/../../init" # for plugins
  require 'rspec/rails'

  RSpec.configure do |config|
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.include RSpec::Rails::ControllerExampleGroup, :example_group => { :file_path => /controller(.)*_spec.rb$/ }#:file_path => /\bspec[\\\/]controllers[\\\/]/ }

    config.before(:suite) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/core")
    end

    config.after(:suite) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/core")
    end
  end
  
  #----------------------------------------------------------------
  # needed when running individual specs
  require File.join(File.dirname(__FILE__), '..','app','models','user')

  class TestUser < ActiveRecord::Base
    activate_sorcery!
  end

  class TestMailer < ActionMailer::Base

  end

  module Sorcery
    module Model
      module Submodules
        module TestSubmodule
          def my_instance_method
          end
        end
      end
    end
  end

  SUBMODUELS_AUTO_ADDED_CONTROLLER_FILTERS = [:register_last_activity_time_to_db, :deny_banned_user, :validate_session]

  def create_new_user(attributes_hash = nil)
    user_attributes_hash = attributes_hash || {:username => 'gizmo', :email => "bla@bla.com", :password => 'secret'}
    @user = User.new(user_attributes_hash)
    @user.save!
    @user
  end

  def login_user(user = nil)
    user ||= @user
    subject.send(:login_user,user)
    subject.send(:after_login!,user,[user.username,'secret'])
  end

  def logout_user
    subject.send(:logout)
  end

  def clear_user_without_logout
    subject.instance_variable_set(:@logged_in_user,nil)
  end

  # TODO: rename to sorcery_reload!(subs = [], model_opts = {}, controller_opts = {})
  def plugin_model_configure(submodules = [], options = {})
    reload_user_class

    # return to no-module configuration
    ::Sorcery::Controller::Config.init!
    ::Sorcery::Controller::Config.reset!

    # remove all plugin before_filters so they won't fail other tests.
    # I don't like this way, but I didn't find another.
    # hopefully it won't break until Rails 4.
    ApplicationController._process_action_callbacks.delete_if {|c| SUBMODUELS_AUTO_ADDED_CONTROLLER_FILTERS.include?(c.filter) }

    # configure
    ::Sorcery::Controller::Config.submodules = submodules
    ::Sorcery::Controller::Config.user_class = nil # the next line will reset it to User
    ActionController::Base.send(:include,::Sorcery::Controller)

    User.activate_sorcery! do |config|
      options.each do |property,value|
        config.send(:"#{property}=", value)
      end
    end
  end

  # TODO: rename to sorcery_model_property_set(prop, val)
  def plugin_set_model_config_property(property, *values)
    User.class_eval do
      sorcery_config.send(:"#{property}=", *values)
    end
  end

  # TODO: rename to sorcery_controller_property_set(prop, val)
  def plugin_set_controller_config_property(property, value)
    ApplicationController.activate_sorcery! do |config|
      config.send(:"#{property}=", value)
    end
  end

  private

  # reload user class between specs
  # so it will be possible to test the different submodules in isolation
  def reload_user_class
    Object.send(:remove_const,:User)
    load 'user.rb'
  end
  
end

Spork.each_run do
  # This code will be run each time you run your specs.
end