class SorceryActivityLogging < ActiveRecord::Migration
  def self.up
    add_column :<%= model_class_name.tableize %>, :last_login_at,     :datetime, :default => nil
    add_column :<%= model_class_name.tableize %>, :last_logout_at,    :datetime, :default => nil
    add_column :<%= model_class_name.tableize %>, :last_activity_at,  :datetime, :default => nil
    
    add_index :<%= model_class_name.tableize %>, [:last_logout_at, :last_activity_at]
  end

  def self.down
    remove_index :<%= model_class_name.tableize %>, [:last_logout_at, :last_activity_at]
    
    remove_column :<%= model_class_name.tableize %>, :last_activity_at
    remove_column :<%= model_class_name.tableize %>, :last_logout_at
    remove_column :<%= model_class_name.tableize %>, :last_login_at
  end
end