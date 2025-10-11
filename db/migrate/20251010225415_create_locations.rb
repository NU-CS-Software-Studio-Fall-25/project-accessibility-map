# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table(:locations) do |t|
      t.text(:name)
      t.text(:address)
      t.text(:city)
      t.text(:state)
      t.text(:zip)
      t.text(:country)
      t.decimal(:latitude, precision: 10, scale: 8)
      t.decimal(:longitude, precision: 11, scale: 8)

      t.timestamps
    end
  end
end
