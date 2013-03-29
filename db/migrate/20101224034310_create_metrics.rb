class CreateMetrics < ActiveRecord::Migration
  def self.up
    create_table :metrics do |t|
      t.date :fulldate
      t.integer :dayofweek
      t.integer :dayofyear
      t.integer :weekofyear
      t.integer :monthofyear
      t.integer :year
      t.integer :movingaverage, :default => 0
      t.integer :population
      t.integer :segment_id

      t.timestamps
    end
    add_index :metrics, :movingaverage, :unique => false
  end

  def self.down
    drop_table :metrics
  end
end
