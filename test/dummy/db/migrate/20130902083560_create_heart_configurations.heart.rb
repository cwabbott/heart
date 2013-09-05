# This migration comes from heart (originally 20130902081333)
class CreateHeartConfigurations < ActiveRecord::Migration
  def change
    create_table :heart_configurations do |t|
      t.string :auth
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
