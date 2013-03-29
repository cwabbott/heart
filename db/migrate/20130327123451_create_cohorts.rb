class CreateCohorts < ActiveRecord::Migration
  def up
    create_table :cohorts do |t|
      t.string :name
      t.text :definition
      t.integer :status
      t.date :start_date

      t.timestamps
    end

    add_column :demographics, :cohort_id, :integer
    add_column :demographics, :cohort_date, :date
  end

  def down
    drop_table :cohorts
    remove_column :demographics, :cohort_id
    remove_column :demographics, :cohort_date
  end
end