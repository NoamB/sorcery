class SorceryExternal < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.integer :<%= model_class_name.tableize.singularize %>_id, :null => false
      t.string :provider, :uid, :null => false

      t.timestamps
    end

    add_index :<%= model_class_name.tableize %>, [:provider, :uid]
  end
end
