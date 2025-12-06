# frozen_string_literal: true

class AddCategoryColumnToFeatures < ActiveRecord::Migration[8.0]
  def change
    add_column(:features, :feature_category, :string, null: false)
  end
end
