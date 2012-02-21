$: << File.join(File.dirname(__FILE__), '..', '..', 'lib' )
# This file is copied to spec/ when you run 'rails generate rspec:install'

# Set the default environment to sqlite3's in_memory database
ENV["RAILS_ENV"] ||= 'in_memory'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'timecop'
# require 'simplecov'
# SimpleCov.root File.join(File.dirname(__FILE__), "..", "..", "rails3" )
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

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include RSpec::Rails::ControllerExampleGroup, :example_group => { :file_path => /controller(.)*_spec.rb$/ }
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  #ActiveRecord::Base.logger = Logger.new(STDOUT)
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
require File.join(File.dirname(__FILE__), '..','app','models','authentication')

class TestUser < ActiveRecord::Base
  authenticates_with_sorcery!
end

class TestMailer < ActionMailer::Base

end

include ::Sorcery::TestHelpers::Internal
include ::Sorcery::TestHelpers::Internal::Rails

