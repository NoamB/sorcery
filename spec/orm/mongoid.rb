require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("sorcery_mongoid_test")
  config.use_utc = true
  config.include_root_in_json = true
end

class TestUser
  include Mongoid::Document
end
