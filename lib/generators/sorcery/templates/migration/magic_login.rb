class SorceryMagicLogin < ActiveRecord::Migration
  def change
    add_column :<%= model_class_name.tableize %>, :magic_login_token, :string, :default => nil
    add_column :<%= model_class_name.tableize %>, :magic_login_token_expires_at, :datetime, :default => nil
    add_column :<%= model_class_name.tableize %>, :magic_login_email_sent_at, :datetime, :default => nil

    add_index :<%= model_class_name.tableize %>, :magic_login_token
  end
end
