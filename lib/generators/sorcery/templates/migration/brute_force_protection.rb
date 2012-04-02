class SorceryBruteForceProtection < ActiveRecord::Migration
  def self.up
    add_column :<%= model_class_name.tableize %>, :failed_logins_count, :integer, :default => 0
    add_column :<%= model_class_name.tableize %>, :lock_expires_at, :datetime, :default => nil
    add_column :<%= model_class_name.tableize %>, :unlock_token, :string, :default => nil
  end

  def self.down
    remove_column :<%= model_class_name.tableize %>, :lock_expires_at
    remove_column :<%= model_class_name.tableize %>, :failed_logins_count
    remove_column :<%= model_class_name.tableize %>, :unlock_token
  end
end