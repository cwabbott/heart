class CreateSegments < ActiveRecord::Migration
  def self.up
    create_table :segments do |t|
      t.integer :demographic_id
      t.string :name
      t.integer :status
      t.date :status_date
      t.integer :division_id
      t.integer :cached_population

      t.timestamps
    end
  end

  def self.down
    drop_table :segments
  end
end
