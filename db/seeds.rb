# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

locations = [
  {
    name: "Moge Tee",
    address: "1590 Sherman Ave",
    city: "Evanston",
    state: "IL",
    zip: "60201",
    country: "US",
  },
  {
    name: "TEAlicious BUBBLE",
    address: "1565 Sherman Ave",
    city: "Evanston",
    state: "IL",
    zip: "60201",
    country: "US",
  },
  {
    name: "UMe Tea",
    address: "618 1/2 Church St",
    city: "Evanston",
    state: "IL",
    zip: "60201",
    country: "US",
  },
  {
    name: "Joy Yee Noodle",
    address: "533 Davis St",
    city: "Evanston",
    state: "IL",
    zip: "60201",
    country: "US",
  },
]

locations.each do |location_data|
  Location.create(location_data)
end
