class AddPasswordExpirationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :password_changed_at, :datetime, :default => nil
  end

  def self.down
    remove_column :users, :password_changed_at
  end
end
