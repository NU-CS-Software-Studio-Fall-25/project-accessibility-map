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
    id: "aea95612-4664-4c6b-990a-0c2aa0c909a6",
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
    id: "254a521b-f0ef-4dfe-bd7d-873059fec190",
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
    id: "b3d52740-3867-497f-bec7-1939c20ea67f",
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
    id: "4f6623d7-276a-4a2f-af22-435eafd7fc65",
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
    id: "b349a7c5-6289-402c-bbef-4f8105feed97",
    location_id: "aea95612-4664-4c6b-990a-0c2aa0c909a6",
    body: "Moge Tee has no ramp to get in and the doorway is elevated so if you need a ramp you are not able to enter.",
  },
  {
    id: "8ce79e05-6b20-4683-8684-05b8461b7f52",
    location_id: "aea95612-4664-4c6b-990a-0c2aa0c909a6",
    body: "I thought the door was pull to open, so I pulled on it really hard and then I tore my bicep",
  },
  {
    id: "ded88c7c-0f3e-4a95-8f6a-24d15b61ffe1",
    location_id: "aea95612-4664-4c6b-990a-0c2aa0c909a6",
    body: "I thought the door was push to open, so I pushed on it really hard and I tore my tricep.",
  },
  {
    id: "b17f21d7-47b8-474a-a6e7-f1cf13ed7f9d",
    location_id: "aea95612-4664-4c6b-990a-0c2aa0c909a6",
    body: "Moge Tee is too narrow for my wheelchair to get through.",
  },
  {
    id: "788b1e7f-75d9-418a-8d9a-ad45dbe5b626",
    location_id: "254a521b-f0ef-4dfe-bd7d-873059fec190",
    body: "Tealicious has a wheelchair accessible ramp.",
  },
  {
    id: "92d59ff9-2cae-4d1d-80ae-2778f08e9cc9",
    location_id: "254a521b-f0ef-4dfe-bd7d-873059fec190",
    body: "Tealicious has a wheelchair-accessible restroom.",
  },
  {
    id: "93f92b43-ad48-4549-bebe-f1669f2482ab",
    location_id: "254a521b-f0ef-4dfe-bd7d-873059fec190",
    body: "It’s easy to get around Tealicious in my wheelchair!",
  },
  {
    id: "d8d42969-cb21-4863-94de-a77785105c15",
    location_id: "254a521b-f0ef-4dfe-bd7d-873059fec190",
    body: "The lighting is not too bright and doesn’t cause sensory issues.",
  },
  {
    id: "0bf2ec78-63c5-412d-a58c-2e3a37d55142",
    location_id: "b3d52740-3867-497f-bec7-1939c20ea67f",
    body: "Ume’s kiosk is not screen-reader friendly.",
  },
  {
    id: "bd61c90e-0315-4436-967a-6e2015720463",
    location_id: "b3d52740-3867-497f-bec7-1939c20ea67f",
    body: "The text on Ume’s physical menu is so small!",
  },
  {
    id: "8d26d03b-efca-44ac-be39-3680f829afba",
    location_id: "b3d52740-3867-497f-bec7-1939c20ea67f",
    body: "Ume’s counter is too tall, so I can’t reach over to grab my drink from my wheelchair.",
  },
  {
    id: "b8a0d1e7-8ea0-4855-936c-a998c636e218",
    location_id: "b3d52740-3867-497f-bec7-1939c20ea67f",
    body: "Ume is pet friendly so I was able to bring my service dog in, which was helpful.",
  },
  {
    id: "31c7bbc7-8ac1-4aa8-9151-aac1fa5f762e",
    location_id: "4f6623d7-276a-4a2f-af22-435eafd7fc65",
    body: "Joyyee has a wheelchair-accessible entrance, seating, and an accessible toilet.",
  },
  {
    id: "778df828-fa76-4e76-94e2-aa9e11dae54b",
    location_id: "4f6623d7-276a-4a2f-af22-435eafd7fc65",
    body: "Joyyee’s tables are too tall, and I cannot reach it from my wheelchair.",
  },
  {
    id: "b2f2bd9e-a6ba-4443-9ee9-0d15f26bfbf2",
    location_id: "4f6623d7-276a-4a2f-af22-435eafd7fc65",
    body: "I liked that Joyyee’s menu was braille-friendly. (disclaimer: i don’t actually know this)",
  },
  {
    id: "11cbff0a-70ba-4dfa-b69e-295107179b11",
    location_id: "4f6623d7-276a-4a2f-af22-435eafd7fc65",
    body: "Joyyee’s tables are spaced out so I can freely move around in my wheelchair.",
  },
]

reviews.each do |review|
  Review.create(review)
end
