class CreateSprinkles < ActiveRecord::Migration[5.1]
  def change
    create_table :sprinkles do |t|
      t.datetime :start_time
      t.string   :time_input
      t.integer  :duration
      t.integer  :valve_id
      t.integer  :state

      t.timestamps
    end
  end
end
