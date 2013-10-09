class AddActivationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :activation_state, :string, :default => nil
    add_column :users, :activation_token, :string, :default => nil
    add_column :users, :activation_token_expires_at, :datetime, :default => nil

    add_index :users, :activation_token
  end

  def self.down
    remove_index :users, :activation_token

    remove_column :users, :activation_token_expires_at
    remove_column :users, :activation_token
    remove_column :users, :activation_state
  end
end
