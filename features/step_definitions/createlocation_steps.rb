When("I visit the new location page") do
  visit new_location_path
end

When("I select {string} from {string}") do |value, field|
  select value, from: field
end

When("I fill in the location name with {string}") do |value|
  fill_in "location[name]", with: value
end
