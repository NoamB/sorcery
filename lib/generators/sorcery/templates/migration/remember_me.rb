class SorceryRememberMe < ActiveRecord::Migration
  def self.up
    add_column :<%= model_class_name.tableize %>, :remember_me_token, :string, :default => nil
    add_column :<%= model_class_name.tableize %>, :remember_me_token_expires_at, :datetime, :default => nil
    
    add_index :<%= model_class_name.tableize %>, :remember_me_token
  end

  def self.down
    remove_index :<%= model_class_name.tableize %>, :remember_me_token
    
    remove_column :<%= model_class_name.tableize %>, :remember_me_token_expires_at
    remove_column :<%= model_class_name.tableize %>, :remember_me_token
  end
end