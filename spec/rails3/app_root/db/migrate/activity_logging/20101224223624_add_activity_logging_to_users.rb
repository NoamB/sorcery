class AddActivityLoggingToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login,     :datetime, :default => nil
    add_column :users, :last_logout,    :datetime, :default => nil
    add_column :users, :last_activity,  :datetime, :default => nil
    
    add_index :users, [:last_logout, :last_activity]
  end

  def self.down
    remove_index :users, [:last_logout, :last_activity]
    
    remove_column :users, :last_activity
    remove_column :users, :last_logout
    remove_column :users, :last_login
  end
end