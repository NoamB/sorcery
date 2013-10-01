class SorceryActivityLogging < ActiveRecord::Migration
  def change
    add_column :<%= model_class_name.tableize %>, :last_login_at,     :datetime, :default => nil
    add_column :<%= model_class_name.tableize %>, :last_logout_at,    :datetime, :default => nil
    add_column :<%= model_class_name.tableize %>, :last_activity_at,  :datetime, :default => nil
    add_column :<%= model_class_name.tableize %>, :last_login_from_ip_address, :string, :default => nil

    add_index :<%= model_class_name.tableize %>, [:last_logout_at, :last_activity_at]
  end
end