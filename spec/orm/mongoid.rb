require 'mongoid'
require 'sorcery'

Mongoid.configure do |config|
  database = "sorcery_mongoid_test"
  if config.respond_to?(:connect_to)
    config.connect_to(database)
  else
    config.master = Mongo::Connection.new.db(database)
  end

  config.use_utc = true
  config.include_root_in_json = true
end

class TestUser
  include Mongoid::Document
end

def setup_orm
  Mongoid.purge!
end
