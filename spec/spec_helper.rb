$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV["RAILS_ENV"] ||= 'test'

SORCERY_ORM = (ENV["SORCERY_ORM"] || :active_record).to_sym

# require 'simplecov'
# SimpleCov.root File.join(File.dirname(__FILE__), '..', 'lib')
# SimpleCov.start

require 'rspec'

require 'rails/all'
require 'rspec/rails'
require 'timecop'

require "rails_app/config/environment"

require "orm/#{SORCERY_ORM}"

class TestMailer < ActionMailer::Base;end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include RSpec::Rails::ControllerExampleGroup, :example_group => { :file_path => /controller(.)*_spec.rb$/ }

  config.mock_with :rspec

  config.use_transactional_fixtures = true

  config.before(:suite) do
    if SORCERY_ORM.to_sym == :active_record
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/core")
    end

    if defined?(Mongoid)
      Mongoid.purge!
    end
  end

  config.after(:suite) do
    if SORCERY_ORM.to_sym == :active_record
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/core")
    end
  end

  config.include ::Sorcery::TestHelpers::Internal
  config.include ::Sorcery::TestHelpers::Internal::Rails
end
