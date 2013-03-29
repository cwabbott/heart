class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :provider
      t.string :uid
      t.string :identifier_url
      t.timestamps
    end
    add_index :users, :identifier_url, :unique => true
  end

  def self.down
    drop_table :users
  end
end
