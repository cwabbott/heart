class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.string :auth
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
