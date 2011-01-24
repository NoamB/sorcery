class AddActivationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :activation_state, :string, :default => nil
    add_column :users, :activation_code, :string, :default => nil
    
    add_index :users, :activation_code
  end

  def self.down
    remove_index :users, :activation_code
    
    remove_column :users, :activation_code
    remove_column :users, :activation_state
  end
end