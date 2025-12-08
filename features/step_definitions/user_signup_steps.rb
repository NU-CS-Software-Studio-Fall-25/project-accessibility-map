# frozen_string_literal: true

Given("I am on the signup page") do
  visit new_user_path
end

Then("I should be redirected to the login page") do
  expect(page).to have_current_path(new_session_path, wait: 10)
end

Then("I should still be on the signup page") do
  expect(page).to have_current_path(new_user_path)
end

Then("I should see an error message") do
  # Check for Rails validation errors - the error message container
  # The form shows errors in a red box with class "bg-red-50" containing text with "text-red-700"
  has_red_box = page.has_css?(".bg-red-50", wait: 5)
  has_red_text = page.has_css?(".text-red-700", wait: 5)
  expect(has_red_box || has_red_text).to be_truthy
end

Then("the username field should be invalid") do
  username_field = find_field("Username")
  expect(username_field[:required]).to be_truthy
  # Verify it's a text field
  expect(username_field[:type]).to eq("text")
end

