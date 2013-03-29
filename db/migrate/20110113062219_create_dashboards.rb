class CreateDashboards < ActiveRecord::Migration
  def self.up
    create_table :dashboards do |t|
      t.string :title
      t.float :eta
      t.text :dashboard
      t.text :description
      t.string :date_from
      t.integer :status
      t.string :supplement
      t.timestamps
    end
  end

  def self.down
    drop_table :dashboards
  end
end
