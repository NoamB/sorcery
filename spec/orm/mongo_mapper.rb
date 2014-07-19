require 'mongo_mapper'
require 'sorcery'

MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = "sorcery_mongomapper_test"

class TestUser
  include MongoMapper::Document
  authenticates_with_sorcery!
end
