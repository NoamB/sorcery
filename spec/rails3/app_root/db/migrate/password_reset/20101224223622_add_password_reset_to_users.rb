class AddPasswordResetToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :reset_password_code, :string, :default => nil
  end

  def self.down
    remove_column :users, :reset_password_code
  end
end