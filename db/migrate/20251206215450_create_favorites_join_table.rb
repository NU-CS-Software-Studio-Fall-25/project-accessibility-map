# frozen_string_literal: true

class CreateFavoritesJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table(:favorites, id: false) do |t|
      t.uuid(:user_id, null: false)
      t.uuid(:location_id, null: false)
      t.index([:user_id, :location_id], unique: true)
      t.index([:location_id, :user_id])
    end

    add_foreign_key(:favorites, :users)
    add_foreign_key(:favorites, :locations)
  end
end
