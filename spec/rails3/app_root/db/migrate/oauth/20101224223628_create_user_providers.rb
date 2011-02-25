class CreateUserProviders < ActiveRecord::Migration
  def self.up
    create_table :user_providers do |t|
      t.integer :user_id, :null => false
      t.string :provider, :access_token, :access_token_secret, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :user_providers
  end
end