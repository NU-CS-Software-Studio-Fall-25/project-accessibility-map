# frozen_string_literal: true

class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table(:reviews) do |t|
      t.references(:location, null: false, foreign_key: true)
      t.text(:body)

      t.timestamps
    end
  end
end
