require File.join(File.dirname(__FILE__), '..', 'myapp.rb')
$: << APP_ROOT # for model reloading

require 'rack/test'
require 'rspec'
require 'timecop'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

module RSpecMixinExample
  include Rack::Test::Methods
  def app
    @app ||= Sinatra::Application
  end
end

Rspec.configure do |config|
  config.send(:include, RSpecMixinExample)
  config.send(:include, ::Sorcery::TestHelpers)
  config.send(:include, ::Sorcery::TestHelpers::Sinatra)
  config.before(:suite) do
    ActiveRecord::Migrator.migrate("#{APP_ROOT}/db/migrate/core")
  end

  config.after(:suite) do
    ActiveRecord::Migrator.rollback("#{APP_ROOT}/db/migrate/core")
  end
  
end

# needed when running individual specs
require File.join(File.dirname(__FILE__), '..','user')
require File.join(File.dirname(__FILE__), '..','authentication')

class TestUser < ActiveRecord::Base
  activate_sorcery!
end

class TestMailer < ActionMailer::Base

end