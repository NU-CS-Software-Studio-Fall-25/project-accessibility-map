# frozen_string_literal: true

class FixSolidCacheEntriesKeyHash < ActiveRecord::Migration[7.2]
  def change
    change_column(:solid_cache_entries, :key_hash, :bigint, null: false)
  end
end
