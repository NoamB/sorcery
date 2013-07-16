class SorceryRememberMe < ActiveRecord::Migration
  def change
    add_column :<%= model_class_name.tableize %>, :remember_me_token, :string, :default => nil
    add_column :<%= model_class_name.tableize %>, :remember_me_token_expires_at, :datetime, :default => nil

    add_index :<%= model_class_name.tableize %>, :remember_me_token
  end
end