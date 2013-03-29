class CreateAnnotations < ActiveRecord::Migration
  def self.up
    create_table :annotations do |t|
      t.date :fulldate
      t.string :note
      t.integer :dashboard_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :annotations
  end
end
