# frozen_string_literal: true

Geocoder.configure(
  lookup: :nominatim,
  timeout: 5,
  units: :mi,

  http_headers: {
    "User-Agent" => "accessibility-map (darianliang2027@u.northwestern.edu)",
    "Referer" => "http://localhost:3000",
  },

  params: {
    email: "darianliang2027@u.northwestern.edu",
  },
)
