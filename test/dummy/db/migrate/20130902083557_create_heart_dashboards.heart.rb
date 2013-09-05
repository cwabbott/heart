# This migration comes from heart (originally 20130902080256)
class CreateHeartDashboards < ActiveRecord::Migration
  def change
    create_table :heart_dashboards do |t|
      t.string :title
      t.text :dashboard
      t.text :description
      t.date :date_from
      t.integer :status
      t.string :supplement
      t.timestamps
    end
  end
end
