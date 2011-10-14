class SorceryExternal < ActiveRecord::Migration
  def self.up
    create_table :authentications do |t|
      t.integer :<%= model_class_name.tableize.singularize %>_id, :null => false
      t.string :provider, :uid, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :authentications
  end
end