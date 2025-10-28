# frozen_string_literal: true

class ChangeJoinTableFeatureIdToUuid < ActiveRecord::Migration[8.0]
  def change
    remove_column(:locations_features, :feature_id, :bigint)
    add_column(:locations_features, :feature_id, :uuid, null: false)
    add_foreign_key(:locations_features, :features, column: :feature_id)
  end
end
