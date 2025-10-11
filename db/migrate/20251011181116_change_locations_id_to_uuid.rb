# frozen_string_literal: true

class ChangeLocationsIdToUuid < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key(:reviews, :locations) if foreign_key_exists?(:reviews, :locations)

    add_column(:locations, :uuid, :uuid, default: "gen_random_uuid()", null: false)

    add_column(:reviews, :location_uuid, :uuid)

    remove_column(:locations, :id)
    rename_column(:locations, :uuid, :id)
    execute("ALTER TABLE locations ADD PRIMARY KEY (id);")

    remove_column(:reviews, :location_id)
    rename_column(:reviews, :location_uuid, :location_id)
    add_index(:reviews, :location_id)

    add_foreign_key(:reviews, :locations)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
