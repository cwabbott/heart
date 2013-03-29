class CreateDemographics < ActiveRecord::Migration
  def self.up
    create_table :demographics do |t|
      t.string :name
      t.text :definition
      t.text :description
      t.text :refreshql
      t.integer :refreshql_replace
      t.integer :auto_assign
      t.integer :initial_population
      t.integer :cached_population
      t.integer :status

      t.timestamps
    end
  end

  def self.down
    drop_table :demographics
  end
end
