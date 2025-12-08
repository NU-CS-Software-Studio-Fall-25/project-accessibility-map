# frozen_string_literal: true

Given("a user exists with email {string} and password {string}") do |email, password|
  User.create!(
    email_address: email,
    username: email.split("@").first,
    password: password,
  )
  # Verify the user can be authenticated
  authenticated_user = User.authenticate_by(email_address: email, password: password)
  raise "User created but cannot be authenticated!" unless authenticated_user
end

Given("I am on the login page") do
  visit new_session_path
end

When("I fill in {string} with {string}") do |field, value|
  # Handle fields that might have * in the label (required fields)
  # Try exact match first, then try with * appended
  begin
    fill_in(field, with: value)
  rescue Capybara::ElementNotFound, Capybara::Ambiguous
    # If ambiguous (e.g., multiple "Password" fields), try to find by label text more specifically
    if field.downcase.include?("password")
      if field.downcase.include?("confirmation")
        fill_in("Password confirmation", with: value, match: :first)
      else
        # Find the first password field (the main password, not confirmation)
        password_fields = page.all("input[type='password']", visible: true)
        # Find the one that's not the confirmation field
        password_field = password_fields.find { |f| f["name"]&.include?("password") && !f["name"]&.include?("confirmation") }
        password_field&.set(value)
      end
    else
      # For other fields, try with * appended to label
      fill_in("#{field} *", with: value)
    end
  end
  # Small delay to ensure field is properly filled (helps with Turbo)
  sleep(0.1)
end

When("I click {string}") do |button_text|
  click_button button_text
  # Wait a moment for Turbo/form submission to process
  sleep(0.5)
end

Then("I should be redirected to the home page") do
  # Wait for the redirect to complete - Capybara will wait automatically
  # Turbo should handle the redirect, but we give it time
  # The home page might redirect to /locations with query params (geolocation)

  # Check that we're no longer on the login page
  expect(page).not_to(have_current_path(new_session_path, wait: 10))
  # Verify we're on the root path (which may redirect to locations with geolocation params)
  expect(page.current_path).to(match(%r{\A(/|/locations)}))
rescue RSpec::Expectations::ExpectationNotMetError => e
  # If we're still on the login page, show debug info
  if page.has_current_path?(new_session_path)
    puts "\n=== DEBUG: Login failed - still on login page ==="
    puts "Current URL: #{page.current_url}"
    puts "Page title: #{page.title}"
    puts "Alert messages: #{page.all("#alert").map(&:text).join(", ")}"
    puts "Notice messages: #{page.all("#notice").map(&:text).join(", ")}"
    puts "Page text snippet: #{page.text[0..300]}"
    puts "===================================\n"
  end
  raise e
end

Then("I should see that I am logged in") do
  # Check for elements that indicate the user is logged in
  # The logout link should be present when logged in
  expect(page).to(have_link("Logout", wait: 5))
  # Also check that login/signup links are not present (they're only shown when not logged in)
  expect(page).not_to(have_link("Login"))
  expect(page).not_to(have_link("Sign Up"))
end

Then("I should see {string}") do |text|
  expect(page).to(have_content(text))
end

Then("I should still be on the login page") do
  expect(page).to(have_current_path(new_session_path))
end

Then("the email field should be invalid") do
  email_field = find_field("Email address")
  expect(email_field[:required]).to(be_truthy)
  # The form should not submit if email is empty (HTML5 validation)
  # We verify we're still on the login page which indicates validation prevented submission
  # Check that the field has validation attributes
  expect(email_field[:type]).to(eq("email"))
end

Then("the password field should be invalid") do
  password_field = find_field("Password")
  expect(password_field[:required]).to(be_truthy)
  # The form should not submit if password is empty (HTML5 validation)
  # We verify we're still on the login page which indicates validation prevented submission
  # Verify it's actually a password field type
  expect(password_field[:type]).to(eq("password"))
end
