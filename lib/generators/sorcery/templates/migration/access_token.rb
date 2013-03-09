class SorceryAccessToken < ActiveRecord::Migration
  def self.up
    create_table :access_tokens do |t|
      t.string :token, :default => nil
      t.boolean :expirable, :default => true
      t.datetime :last_activity_at
      t.references :<%= model_class_name.downcase %>

      t.timestamps
    end
  end

  def self.down
    drop_table :access_tokens
  end
end
