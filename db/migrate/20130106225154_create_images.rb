class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :dashboard_id
      t.string :purpose
      t.text :dataurl, :limit => 4294967295

      t.timestamps
    end
  end
end
