class SorceryCore < ActiveRecord::Migration
  def change
    create_table :<%= model_class_name.tableize %> do |t|
      t.string :email,            :null => false
      t.string :crypted_password, :null => false
      t.string :salt,             :null => false

      t.timestamps
    end

    add_index :<%= model_class_name.tableize %>, :email, unique: true
  end
end