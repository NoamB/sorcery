require 'sorcery'

ActiveRecord::Migration.verbose = false
# ActiveRecord::Base.logger = Logger.new(nil)
# ActiveRecord::Base.include_root_in_json = true

class TestUser < ActiveRecord::Base
  authenticates_with_sorcery!
end

def setup_orm
  ActiveRecord::Migrator.migrate(migrations_path)
end

def teardown_orm
  ActiveRecord::Migrator.rollback(migrations_path)
end

def migrations_path
  Rails.root.join("db", "migrate", "core")
end
