class CreateIsometrics < ActiveRecord::Migration
  def self.up
    create_table :isometrics do |t|
      t.date :fulldate
      t.integer :movingaverage, :default => 0
      t.datetime :population
      t.integer :segment_id
      t.timestamps
    end
  end

  def self.down
    drop_table :isometrics
  end
end
