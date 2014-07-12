require 'data_mapper'
require 'dm-migrations'
require 'sorcery'

#DataMapper.setup(:default, 'sqlite::memory:')
# NOTE
# 1. Problems with Time fields, hh mm ss values.
#DataMapper.setup(:default, "sqlite3://#{File.dirname(__FILE__)}/../rails_app/test.sqlite3")

# MySQL
# NOTE
# 1. Create test database.
# 2. DM creates tables case insensitive by default.
# -
#DataMapper.setup(:default, "mysql://root:<password>@localhost/sorcery_test")
DataMapper.setup(:default, "mysql://root@127.0.0.1/sorcery_test")

# Redis
# NOTE
# 1. Submodule activity_logging is not supported.
# 2. case sensitive.
#DataMapper.setup(:default, {
#  :adapter => 'redis',
#  :host    => 'localhost',
#  :port    => 6379,
#})

class TestUser
  include DataMapper::Resource
  property :id, Serial
  authenticates_with_sorcery!
end

def setup_orm
  TestUser.finalize
  DataMapper.auto_migrate!
end

module Sorcery
  module TestHelpers
    module Internal
      def update_model(&block)
        User.class_exec(&block)
        User.finalize
      end
    end
  end
end
