class CreateWaterManagers < ActiveRecord::Migration[5.1]
  def change
    create_table :water_managers do |t|
      t.integer :state
      t.integer :key
      t.integer :scheduling_option

      t.timestamps
    end
  end
end
