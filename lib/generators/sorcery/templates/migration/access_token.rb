class SorceryAccessToken < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.string :token, :default => nil
      t.boolean :expirable, :default => true
      t.datetime :last_activity_at
      t.references :<%= model_class_name.downcase %>

      t.timestamps
    end
  end
end
