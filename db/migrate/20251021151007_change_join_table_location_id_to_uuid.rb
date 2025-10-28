# frozen_string_literal: true

class ChangeJoinTableLocationIdToUuid < ActiveRecord::Migration[8.0]
  def change
    remove_column(:locations_features, :location_id, :bigint)
    add_column(:locations_features, :location_id, :uuid, null: false)
    add_foreign_key(:locations_features, :locations, column: :location_id)
  end
end
