# This migration comes from heart (originally 20130902051427)
class CreateHeartIsometrics < ActiveRecord::Migration
  def change
    create_table :heart_isometrics do |t|
      t.date :fulldate
      t.integer :movingaverage, :default => 0
      t.timestamps
    end
  end
end
