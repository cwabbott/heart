class CreateHeartAnnotations < ActiveRecord::Migration
  def change
    create_table :heart_annotations do |t|
      t.date :fulldate
      t.string :note
      t.integer :dashboard_id
      t.timestamps
    end
  end
end
