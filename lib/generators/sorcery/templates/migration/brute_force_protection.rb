class SorceryBruteForceProtection < ActiveRecord::Migration
  def change
    add_column :<%= model_class_name.tableize %>, :failed_logins_count, :integer, :default => 0
    add_column :<%= model_class_name.tableize %>, :lock_expires_at, :datetime, :default => nil
    add_column :<%= model_class_name.tableize %>, :unlock_token, :string, :default => nil

    add_index :<%= model_class_name.tableize %>, :unlock_token
  end
end
