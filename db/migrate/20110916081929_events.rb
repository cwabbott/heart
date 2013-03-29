class Events < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :user_id
      t.integer :total
      t.string :metric
      t.date :fulldate

      t.timestamps
    end
    add_index(:events, "metric")
    add_index(:events, "fulldate")
  end

  def self.down
    drop_table :events
  end
end
