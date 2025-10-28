# frozen_string_literal: true

class AddUserToReviews < ActiveRecord::Migration[8.0]
  def change
    add_reference(:reviews, :user, null: false, foreign_key: true, type: :uuid)
  end
end
