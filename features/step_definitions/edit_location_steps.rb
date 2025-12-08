# frozen_string_literal: true

Given("I have a location named {string} at {string}") do |name, address|
  user = User.find_by(email_address: "test@example.com")
  raise "User not found!" unless user

  # Parse address components
  parts = address.split(',').map(&:strip)
  street = parts[0]
  city = parts[1]
  state_zip = parts[2] || 'IL 60601'
  state_parts = state_zip.split
  state = state_parts[0]
  zip = state_parts[1] || '60601'
  country = parts[3] || 'United States'

  @location = Location.create!(
    user: user,
    name: name,
    address: street,
    city: city,
    state: state,
    zip: zip,
    country: country,
    latitude: 41.8781,
    longitude: -87.6298
  )
end

Given("a location exists named {string} at {string}") do |name, address|
  # Create location for any user (for testing authorization)
  user = User.first || User.create!(
    email_address: "default@example.com",
    username: "defaultuser",
    password: "DefaultPassword123!"
  )

  # Parse address components
  parts = address.split(',').map(&:strip)
  street = parts[0]
  city = parts[1]
  state_zip = parts[2] || 'IL 60601'
  state_parts = state_zip.split
  state = state_parts[0]
  zip = state_parts[1] || '60601'
  country = parts[3] || 'United States'

  Location.create!(
    user: user,
    name: name,
    address: street,
    city: city,
    state: state,
    zip: zip,
    country: country,
    latitude: 41.8781,
    longitude: -87.6298
  )
end

Given("another user exists with email {string} and password {string}") do |email, password|
  User.create!(
    email_address: email,
    username: email.split("@").first,
    password: password
  )
end

Given("that user has a location named {string} at {string}") do |name, address|
  user = User.find_by(email_address: "other@example.com")
  raise "Other user not found!" unless user

  # Parse address components
  parts = address.split(',').map(&:strip)
  street = parts[0]
  city = parts[1]
  state_zip = parts[2] || 'IL 60601'
  state_parts = state_zip.split
  state = state_parts[0]
  zip = state_parts[1] || '60601'
  country = parts[3] || 'United States'

  Location.create!(
    user: user,
    name: name,
    address: street,
    city: city,
    state: state,
    zip: zip,
    country: country,
    latitude: 41.8781,
    longitude: -87.6298
  )
end

Given("I am on the edit page for the location {string}") do |location_name|
  location = Location.find_by(name: location_name)
  raise "Location '#{location_name}' not found!" unless location
  visit edit_location_path(location)

  # Wait for the page to load and ensure address fields are populated
  # The form should have the address pre-filled, but we need to wait for JavaScript
  sleep(0.5)

  # Ensure the address autocomplete validation runs and enables the submit button
  # If address fields exist, trigger validation
  page.execute_script(%{
    const addressField = document.querySelector('[data-address-autocomplete-target="addressField"]');
    const cityField = document.querySelector('[data-address-autocomplete-target="cityField"]');
    const stateField = document.querySelector('[data-address-autocomplete-target="stateField"]');
    const zipField = document.querySelector('[data-address-autocomplete-target="zipField"]');
    const countryField = document.querySelector('[data-address-autocomplete-target="countryField"]');
    const latField = document.querySelector('[data-address-autocomplete-target="latitudeField"]');
    const lngField = document.querySelector('[data-address-autocomplete-target="longitudeField"]');
    const form = document.querySelector('[data-controller*="address-autocomplete"]');

    // If fields exist and have values, ensure validation runs
    if (form && form.addressAutocompleteController) {
      form.addressAutocompleteController.validateFields();
    } else if (addressField && addressField.value) {
      // Trigger validation by dispatching an input event
      addressField.dispatchEvent(new Event('input', { bubbles: true }));
    }
  })
  sleep(0.2)
end

When("I try to visit the edit page for {string}") do |location_name|
  location = Location.find_by(name: location_name)
  raise "Location '#{location_name}' not found!" unless location
  visit edit_location_path(location)
end

When("I clear the location name field") do
  name_field = find_field("Location Name")
  name_field.set("")
end

When("I clear the address fields") do
  # Clear the address search input and hidden fields
  page.execute_script(%{
    const searchInput = document.querySelector('[data-address-autocomplete-target="searchInput"]');
    const addressField = document.querySelector('[data-address-autocomplete-target="addressField"]');
    const cityField = document.querySelector('[data-address-autocomplete-target="cityField"]');
    const stateField = document.querySelector('[data-address-autocomplete-target="stateField"]');
    const zipField = document.querySelector('[data-address-autocomplete-target="zipField"]');
    const countryField = document.querySelector('[data-address-autocomplete-target="countryField"]');

    if (searchInput) searchInput.value = '';
    if (addressField) addressField.value = '';
    if (cityField) cityField.value = '';
    if (stateField) stateField.value = '';
    if (zipField) zipField.value = '';
    if (countryField) countryField.value = '';
  })
  sleep(0.2)
end

When("I set invalid address coordinates") do
  # Set address fields but leave coordinates blank to trigger validation
  page.execute_script(%{
    const addressField = document.querySelector('[data-address-autocomplete-target="addressField"]');
    const cityField = document.querySelector('[data-address-autocomplete-target="cityField"]');
    const stateField = document.querySelector('[data-address-autocomplete-target="stateField"]');
    const zipField = document.querySelector('[data-address-autocomplete-target="zipField"]');
    const countryField = document.querySelector('[data-address-autocomplete-target="countryField"]');
    const latField = document.querySelector('[data-address-autocomplete-target="latitudeField"]');
    const lngField = document.querySelector('[data-address-autocomplete-target="longitudeField"]');

    // Set address components but leave coordinates empty
    if (addressField) addressField.value = 'Invalid Address';
    if (cityField) cityField.value = 'Invalid City';
    if (stateField) stateField.value = 'XX';
    if (zipField) zipField.value = '00000';
    if (countryField) countryField.value = 'United States';
    // Leave coordinates blank to trigger validation error
    if (latField) latField.value = '';
    if (lngField) lngField.value = '';
  })
  sleep(0.2)
end

Then("I should still be on the edit location page") do
  expect(page.current_path).to match(/\A\/locations\/[^\/]+\/edit\z/)
end

Then("I should see an alert message with {string}") do |text|
  # Check for flash alert messages (displayed in #alert element)
  expect(page).to have_css("#alert", text: text, wait: 5)
end

