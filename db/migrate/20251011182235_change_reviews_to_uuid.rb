# frozen_string_literal: true

class ChangeReviewsToUuid < ActiveRecord::Migration[8.0]
  def up
    add_column(:reviews, :uuid, :uuid, default: "gen_random_uuid()", null: false)

    remove_column(:reviews, :id)
    rename_column(:reviews, :uuid, :id)
    execute("ALTER TABLE reviews ADD PRIMARY KEY (id);")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
