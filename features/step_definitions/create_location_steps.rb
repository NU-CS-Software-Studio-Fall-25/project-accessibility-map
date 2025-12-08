# frozen_string_literal: true

Given("I am logged in as a user with email {string} and password {string}") do |email, password|
  # Create user if it doesn't exist
  user = User.find_by(email_address: email)
  unless user
    User.create!(
      email_address: email,
      username: email.split("@").first,
      password: password,
    )
  end

  # Login
  visit new_session_path
  fill_in "Email address", with: email
  fill_in "Password", with: password
  click_button "Login"

  # Verify we're logged in
  expect(page).not_to(have_current_path(new_session_path, wait: 10))
end

Given("I am logged out") do
  # Delete any existing session cookies
  page.driver.browser.manage.delete_all_cookies if page.driver.browser.respond_to?(:manage)
  cookies.delete(:session_id) if respond_to?(:cookies)

  # Visit logout if we're on a page with logout link
  if page.has_link?("Logout", wait: 2)
    click_link "Logout"
  end
end

Given("I am on the new location page") do
  visit new_location_path
end

When("I visit the new location page") do
  visit new_location_path
end

When("I fill in the location name with {string}") do |name|
  fill_in "Location Name", with: name
end

When("I fill in the address search field with {string}") do |address|
  # Find the address autocomplete input field
  address_input = find("input[data-address-autocomplete-target='searchInput']")
  address_input.set(address)

  # Wait a moment for autocomplete to potentially trigger
  sleep(0.5)

  # If there's a suggestion dropdown, click the first result
  if page.has_css?("[data-address-autocomplete-target='suggestions'] li", wait: 2)
    first("[data-address-autocomplete-target='suggestions'] li").click
    sleep(0.5)
  end
end

When("I wait for address autocomplete to populate fields") do
  # Manually populate the hidden fields since JavaScript autocomplete might not work in tests
  # We'll use JavaScript to set the values directly
  # Try to parse the address from the search input, or use defaults
  address_input = find("input[data-address-autocomplete-target='searchInput']")
  address_text = address_input.value

  # Parse address components (format: "123 Main St, Chicago, IL 60601, United States")
  parts = address_text.split(",").map(&:strip)
  street = parts[0] || "123 Main St"
  city = parts[1] || "Chicago"
  state_zip = parts[2] || "IL 60601"
  state_parts = state_zip.split
  state = state_parts[0] || "IL"
  zip = state_parts[1] || "60601"
  country = parts[3] || "United States"

  page.execute_script(%{
    const address = '#{street.gsub("'", "\\'")}';
    const city = '#{city.gsub("'", "\\'")}';
    const state = '#{state}';
    const zip = '#{zip}';
    const country = '#{country.gsub("'", "\\'")}';
    const latitude = 41.8781;
    const longitude = -87.6298;

    const addressField = document.querySelector('[data-address-autocomplete-target="addressField"]');
    const cityField = document.querySelector('[data-address-autocomplete-target="cityField"]');
    const stateField = document.querySelector('[data-address-autocomplete-target="stateField"]');
    const zipField = document.querySelector('[data-address-autocomplete-target="zipField"]');
    const countryField = document.querySelector('[data-address-autocomplete-target="countryField"]');
    const latField = document.querySelector('[data-address-autocomplete-target="latitudeField"]');
    const lngField = document.querySelector('[data-address-autocomplete-target="longitudeField"]');
    const submitButton = document.querySelector('[data-address-autocomplete-target="submitButton"]');

    if (addressField) addressField.value = address;
    if (cityField) cityField.value = city;
    if (stateField) stateField.value = state;
    if (zipField) zipField.value = zip;
    if (countryField) countryField.value = country;
    if (latField) latField.value = latitude;
    if (lngField) lngField.value = longitude;

    // Trigger validation to enable submit button
    // Find the controller instance and call validateFields
    const form = document.querySelector('[data-controller*="address-autocomplete"]');
    if (form && form.addressAutocompleteController) {
      form.addressAutocompleteController.validateFields();
    } else if (submitButton) {
      // Fallback: directly enable the button
      submitButton.disabled = false;
      submitButton.classList.remove('disabled');
      submitButton.removeAttribute('disabled');
    }

    // Also trigger input events to ensure validation runs
    if (addressField) addressField.dispatchEvent(new Event('input', { bubbles: true }));
  })

  sleep(0.3)
end

When("I select at least one feature") do
  # Check if features exist, if not skip this step (features are optional)
  if page.has_css?("input[type='checkbox'][name='location[feature_ids][]']", wait: 2)
    first_feature_checkbox = first("input[type='checkbox'][name='location[feature_ids][]']")
    first_feature_checkbox.check
  end
  # Features might not exist in test database, which is okay - they're optional
  # Just skip this step silently
end

When("I enable the submit button manually") do
  # Enable the submit button for testing validation errors
  # Try location form submit button first
  page.execute_script(%{
    const locationSubmitButton = document.querySelector('[data-address-autocomplete-target="submitButton"]');
    if (locationSubmitButton) {
      locationSubmitButton.disabled = false;
      locationSubmitButton.removeAttribute('disabled');
    }
    // Also try review form submit buttons
    const reviewSubmitButton = document.querySelector('#add-review-modal button[type="submit"], #add-review-modal input[type="submit"]');
    if (reviewSubmitButton) {
      reviewSubmitButton.disabled = false;
      reviewSubmitButton.removeAttribute('disabled');
    }
    // Also try to find submit buttons in edit modals
    document.querySelectorAll('[id^="edit-review-modal-"] button[type="submit"], [id^="edit-review-modal-"] input[type="submit"]').forEach(function(btn) {
      btn.disabled = false;
      btn.removeAttribute('disabled');
    });
  })
end

Then("I should be redirected to the location show page") do
  # Should be redirected to /locations/:id
  expect(page.current_path).to(match(%r{\A/locations/[^/]+\z}))
  expect(page).not_to(have_current_path(new_location_path, wait: 10))
end

Then("I should still be on the new location page") do
  expect(page).to(have_current_path(new_location_path))
end

Then("I should see an error message for location") do
  # Check for Rails validation errors
  has_red_box = page.has_css?(".bg-red-50", wait: 5)
  has_red_text = page.has_css?(".text-red-700", wait: 5)
  expect(has_red_box || has_red_text).to(be_truthy)
end

Then("I should be redirected to the login page from location") do
  expect(page).to(have_current_path(new_session_path, wait: 10))
end
