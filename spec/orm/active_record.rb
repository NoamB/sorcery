ActiveRecord::Migration.verbose = false
# ActiveRecord::Base.logger = Logger.new(nil)
# ActiveRecord::Base.include_root_in_json = true

class TestUser < ActiveRecord::Base
  authenticates_with_sorcery!
end
