require 'data_mapper'
require 'dm-types'
#DataMapper.setup(:default, 'sqlite::memory:')
# NOTE Found problems with Time fields
#DataMapper.setup(:default, "sqlite3://#{File.dirname(__FILE__)}/../rails_app/test.sqlite3")
DataMapper.setup(:default, "mysql://root:<password>@localhost/sorcery_test")

class TestUser
  include DataMapper::Resource
  property :id, Serial
  authenticates_with_sorcery!
end
TestUser.finalize

require  'dm-migrations'
DataMapper.auto_migrate!
