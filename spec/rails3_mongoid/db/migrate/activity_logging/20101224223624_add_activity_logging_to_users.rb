class AddActivityLoggingToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login_at,     :datetime, :default => nil
    add_column :users, :last_logout_at,    :datetime, :default => nil
    add_column :users, :last_activity_at,  :datetime, :default => nil
    
    add_index :users, [:last_logout_at, :last_activity_at]
  end

  def self.down
    remove_index :users, [:last_logout_at, :last_activity_at]
    
    remove_column :users, :last_activity_at
    remove_column :users, :last_logout_at
    remove_column :users, :last_login_at
  end
end