class SorceryUserActivation < ActiveRecord::Migration
  def change
    add_column :<%= model_class_name.tableize %>, :activation_state, :string, :default => nil
    add_column :<%= model_class_name.tableize %>, :activation_token, :string, :default => nil
    add_column :<%= model_class_name.tableize %>, :activation_token_expires_at, :datetime, :default => nil

    add_index :<%= model_class_name.tableize %>, :activation_token
  end
end