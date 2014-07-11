class AddApprovalToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :approval_state, :string, :default => nil
  end

  def self.down
    remove_column :users, :approval_state
  end
end
