# frozen_string_literal: true

class CreateJoinLocationsFeatures < ActiveRecord::Migration[8.0]
  def change
    create_join_table(:locations, :features, table_name: :locations_features) do |t|
      t.index([:location_id, :feature_id])
      t.index([:feature_id, :location_id])
    end
  end
end
