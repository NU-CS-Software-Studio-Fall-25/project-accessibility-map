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
    id: 1,
    name: "Moge Tee",
    address: "1590 Sherman Ave",
    city: "Evanston",
    state: "IL",
    zip: "60201",
    country: "US",
    latitude: 42.0466157,
    longitude: -87.6820545,
  },
  {
    id: 2,
    name: "TEAlicious BUBBLE",
    address: "1565 Sherman Ave",
    city: "Evanston",
    state: "IL",
    zip: "60201",
    country: "US",
    latitude: 42.0460238,
    longitude: -87.6815938,
  },
  {
    id: 3,
    name: "UMe Tea",
    address: "618 1/2 Church St",
    city: "Evanston",
    state: "IL",
    zip: "60201",
    country: "US",
    latitude: 42.047894,
    longitude: -87.6800271,
  },
  {
    id: 4,
    name: "Joy Yee Noodle",
    address: "533 Davis St",
    city: "Evanston",
    state: "IL",
    zip: "60201",
    country: "US",
    latitude: 42.0462518,
    longitude: -87.6792726,
  },
]

locations.each do |location|
  Location.create(location)
end

reviews = [
  {
    id: 1,
    location_id: 1,
    body: "Moge Tee has no ramp to get in and the doorway is elevated so if you need a ramp you are not able to enter.",
  },
  {
    id: 2,
    location_id: 1,
    body: "I thought the door was pull to open, so I pulled on it really hard and then I tore my bicep",
  },
  {
    id: 3,
    location_id: 1,
    body: "I thought the door was push to open, so I pushed on it really hard and I tore my tricep.",
  },
  {
    id: 4,
    location_id: 1,
    body: "Moge Tee is too narrow for my wheelchair to get through.",
  },
  {
    id: 5,
    location_id: 2,
    body: "Tealicious has a wheelchair accessible ramp.",
  },
  {
    id: 6,
    location_id: 2,
    body: "Tealicious has a wheelchair-accessible restroom.",
  },
  {
    id: 7,
    location_id: 2,
    body: "It’s easy to get around Tealicious in my wheelchair!",
  },
  {
    id: 8,
    location_id: 2,
    body: "The lighting is not too bright and doesn’t cause sensory issues.",
  },
  {
    id: 9,
    location_id: 3,
    body: "Ume’s kiosk is not screen-reader friendly.",
  },
  {
    id: 10,
    location_id: 3,
    body: "The text on Ume’s physical menu is so small!",
  },
  {
    id: 11,
    location_id: 3,
    body: "Ume’s counter is too tall, so I can’t reach over to grab my drink from my wheelchair.",
  },
  {
    id: 12,
    location_id: 3,
    body: "Ume is pet friendly so I was able to bring my service dog in, which was helpful.",
  },
  {
    id: 13,
    location_id: 4,
    body: "Joyyee has a wheelchair-accessible entrance, seating, and an accessible toilet.",
  },
  {
    id: 14,
    location_id: 4,
    body: "Joyyee’s tables are too tall, and I cannot reach it from my wheelchair.",
  },
  {
    id: 15,
    location_id: 4,
    body: "I liked that Joyyee’s menu was braille-friendly. (disclaimer: i don’t actually know this)",
  },
  {
    id: 16,
    location_id: 4,
    body: "Joyyee’s tables are spaced out so I can freely move around in my wheelchair.",
  },
]

reviews.each do |review|
  Review.create(review)
end
