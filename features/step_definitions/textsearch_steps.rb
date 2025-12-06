# frozen_string_literal: true

Given("I am logged in as {string}") do |email|
  visit new_session_path

  fill_in "Email address", with: email
  fill_in "Password", with: @users[email]

  click_button "Login"
end

Given("the following locations exist:") do |table|
  table.hashes.each do |row|
    user = User.find_by(email_address: row["user_email"])
    raise "User #{row["user_email"]} not found" unless user

    Location.create!(
      name: row["name"],
      address: row["address"],
      city: row["city"],
      state: row["state"],
      zip: row["zip"],
      country: row["country"],
      user_id: user.id,
    )
  end
end

When("I visit the search page") do
  visit locations_path
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I press {string}") do |button|
  click_button button
end

Then("I should see {string}") do |text|
  expect(page).to(have_content(text))
end

Then("I should not see {string}") do |text|
  expect(page).not_to(have_content(text))
end
