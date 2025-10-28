# frozen_string_literal: true

class FixSolidCacheEntriesSchema < ActiveRecord::Migration[7.2]
  def change
    # Change 'key' column type to binary with explicit cast
    change_column :solid_cache_entries, :key, 'bytea USING key::bytea', limit: 1024, null: false

    # Change 'value' column type to binary with explicit cast
    change_column :solid_cache_entries, :value, 'bytea USING value::bytea', limit: 536870912, null: false

    # Remove extra columns if they exist
    remove_column :solid_cache_entries, :hits, :integer if column_exists?(:solid_cache_entries, :hits)
    remove_column :solid_cache_entries, :expires_at, :datetime if column_exists?(:solid_cache_entries, :expires_at)
    remove_column :solid_cache_entries, :updated_at, :datetime if column_exists?(:solid_cache_entries, :updated_at)

    # Add missing 'byte_size' column
    add_column :solid_cache_entries, :byte_size, :integer, limit: 4, null: false unless column_exists?(:solid_cache_entries, :byte_size)

    # Remove old indexes
    remove_index :solid_cache_entries, :key if index_exists?(:solid_cache_entries, :key)
    
    # Add the correct indexes
    add_index :solid_cache_entries, :byte_size, name: "index_solid_cache_entries_on_byte_size" unless index_exists?(:solid_cache_entries, :byte_size)
    add_index :solid_cache_entries, [:key_hash, :byte_size], name: "index_solid_cache_entries_on_key_hash_and_byte_size" unless index_exists?(:solid_cache_entries, [:key_hash, :byte_size])
    add_index :solid_cache_entries, :key_hash, unique: true, name: "index_solid_cache_entries_on_key_hash" unless index_exists?(:solid_cache_entries, :key_hash)
  end
end
