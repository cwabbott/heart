class CreatePopulations < ActiveRecord::Migration
  def self.up
    create_table :populations do |t|
      t.integer :demographic_id
      t.integer :user_id
      t.integer :segment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :populations
  end
end
