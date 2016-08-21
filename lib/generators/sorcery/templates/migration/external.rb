class SorceryExternal < <%= migration_class_name %>
  def change
    create_table :authentications do |t|
      t.integer :<%= model_class_name.tableize.singularize %>_id, :null => false
      t.string :provider, :uid, :null => false

      t.timestamps              :null => false
    end

    add_index :authentications, [:provider, :uid]
  end
end
