class CreateHeartImages < ActiveRecord::Migration
  def change
    create_table :heart_images do |t|
      t.integer :dashboard_id
      t.string :purpose
      t.text :dataurl, :limit => 4294967295

      t.timestamps
    end
  end
end
