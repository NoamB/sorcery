class AddResetPasswordToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :reset_password_token, :string, :default => nil
    add_column :users, :reset_password_token_expires_at, :datetime, :default => nil
    add_column :users, :reset_password_email_sent_at, :datetime, :default => nil
  end

  def self.down
    remove_column :users, :reset_password_email_sent_at
    remove_column :users, :reset_password_token_expires_at
    remove_column :users, :reset_password_token
  end
end