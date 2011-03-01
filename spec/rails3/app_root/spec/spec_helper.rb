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
  require File.join(File.dirname(__FILE__), '..','app','models','user_provider')

  class TestUser < ActiveRecord::Base
    activate_sorcery!
  end

  class TestMailer < ActionMailer::Base

  end
  
  include ::Sorcery::TestHelpers
  
end

Spork.each_run do
  # This code will be run each time you run your specs.
end