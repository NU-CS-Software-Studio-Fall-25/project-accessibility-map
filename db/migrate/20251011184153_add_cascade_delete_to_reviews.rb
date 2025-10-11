# frozen_string_literal: true

class AddCascadeDeleteToReviews < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key(:reviews, :locations)

    add_foreign_key(:reviews, :locations, on_delete: :cascade)
  end
end
