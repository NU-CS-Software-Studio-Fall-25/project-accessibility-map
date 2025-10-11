# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_11_184153) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text("name")
    t.text("address")
    t.text("city")
    t.text("state")
    t.text("zip")
    t.text("country")
    t.decimal("latitude", precision: 10, scale: 8)
    t.decimal("longitude", precision: 11, scale: 8)
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
  end

  create_table "reviews", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text("body")
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
    t.uuid("location_id")
    t.index(["location_id"], name: "index_reviews_on_location_id")
  end

  add_foreign_key "reviews", "locations", on_delete: :cascade
end
