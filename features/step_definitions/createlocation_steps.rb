# frozen_string_literal: true

Given("that the following users exists:") do |table|
  @users = {}
  table.hashes.each do |row|
    User.create!(
      email_address: row["email_address"],
      password: row["password"],
      password_confirmation: row["password"],
    )
    @users[row["email_address"]] = row["password"]
  end
end

When("I visit the new location page") do
  visit new_location_path
end

When("I check feature {string}") do |label_text|
  check(label_text)
end

When("I select {string} from {string}") do |value, field|
  select value, from: field
end

When("I fill in the location name with {string}") do |value|
  fill_in "location[name]", with: value
end
