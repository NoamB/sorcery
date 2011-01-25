class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :email, :null => false
      t.string :crypted_password
      t.string :salt

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end