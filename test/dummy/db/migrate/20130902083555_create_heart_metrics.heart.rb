# This migration comes from heart (originally 20130902050854)
class CreateHeartMetrics < ActiveRecord::Migration
  def change
    create_table :heart_metrics do |t|
      t.date :fulldate
      t.integer :dayofweek
      t.integer :dayofyear
      t.integer :weekofyear
      t.integer :monthofyear
      t.integer :year
      t.integer :movingaverage, :default => 0

      t.timestamps
    end
    add_index :heart_metrics, :movingaverage, :unique => false
  end
end
