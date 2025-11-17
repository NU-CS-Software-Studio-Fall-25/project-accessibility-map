# frozen_string_literal: true

class FixSolidCacheEntriesByteSize < ActiveRecord::Migration[7.2]
  def change
    # Change byte_size to bigint to avoid integer range errors
    change_column(:solid_cache_entries, :byte_size, :bigint, null: false)
  end
end
