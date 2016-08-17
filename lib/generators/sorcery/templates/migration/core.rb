class SorceryCore < <%= migration_class_name %>
  def change
    create_table :<%= model_class_name.tableize %> do |t|
      t.string :email,            :null => false
      t.string :crypted_password
      t.string :salt

      t.timestamps                :null => false
    end

    add_index :<%= model_class_name.tableize %>, :email, unique: true
  end
end
