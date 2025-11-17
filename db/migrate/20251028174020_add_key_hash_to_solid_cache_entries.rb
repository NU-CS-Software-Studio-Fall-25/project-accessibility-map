# frozen_string_literal: true

class AddKeyHashToSolidCacheEntries < ActiveRecord::Migration[7.2]
  def change
    add_column(:solid_cache_entries, :key_hash, :integer, null: false)
    add_index(:solid_cache_entries, :key_hash, unique: true)
  end
end
