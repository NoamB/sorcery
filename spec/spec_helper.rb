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

require "orm/#{SORCERY_ORM}"

require "rails_app/config/environment"

class TestMailer < ActionMailer::Base;end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include RSpec::Rails::ControllerExampleGroup, :file_path => /controller(.)*_spec.rb$/
  config.filter_run_excluding :active_record => SORCERY_ORM.to_sym != :active_record
  config.filter_run_excluding :mongo_mapper => SORCERY_ORM.to_sym != :mongo_mapper
  config.filter_run_excluding :datamapper => SORCERY_ORM.to_sym != :datamapper
  config.filter_run_excluding :mongoid => SORCERY_ORM.to_sym != :mongoid
  config.mock_with :rspec

  config.use_transactional_fixtures = true

  migrations_path = Rails.root.join("db", "migrate", "core")

  config.before(:suite) do
    if SORCERY_ORM.to_sym == :active_record
      ActiveRecord::Migrator.migrate(migrations_path)
    end
    if SORCERY_ORM.to_sym == :datamapper
      DataMapper.auto_migrate!
      DataMapper.finalize
    end

    if defined?(Mongoid)
      Mongoid.purge!
    end
  end

  config.after(:suite) do
    if SORCERY_ORM.to_sym == :active_record
      ActiveRecord::Migrator.rollback(migrations_path)
    end
  end

  config.include ::Sorcery::TestHelpers::Internal
  config.include ::Sorcery::TestHelpers::Internal::Rails
end
