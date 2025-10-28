# frozen_string_literal: true

class AddUserToLocations < ActiveRecord::Migration[8.0]
  def change
    add_reference(:locations, :user, null: false, foreign_key: true, type: :uuid)
  end
end
