# frozen_string_literal: true

Given("I am on the password reset request page") do
  visit new_password_path
end

When("I visit the password reset edit page with the token") do
  visit edit_password_path(@password_reset_token)
end

When("I visit the password reset edit page with token {string}") do |token|
  visit edit_password_path(token)
end

When("I extract the password reset token from the email") do
  # Wait for email to be delivered (deliver_later enqueues to SolidQueue)
  # Process any queued jobs to ensure emails are delivered
  begin
    # Try to process enqueued jobs if ActiveJob test helpers are available
    if defined?(ActiveJob::TestHelper)
      perform_enqueued_jobs
    else
      # For SolidQueue, we might need to process jobs manually
      # But in test environment, deliver_later might actually deliver immediately
      sleep(0.5)
    end
  rescue => e
    # If job processing fails, just wait a bit
    sleep(0.5)
  end

  # Get the last email sent
  email = ActionMailer::Base.deliveries.last
  raise "No email was sent! Total deliveries: #{ActionMailer::Base.deliveries.count}" unless email

  # Extract the token from the email body (try text first, then HTML)
  email_body = if email.text_part
    email.text_part.body.to_s
  elsif email.html_part
    email.html_part.body.to_s
  else
    email.body.to_s
  end

  # The token is in a URL like: http://example.com/passwords/:token/edit or /passwords/:token/edit
  token_match = email_body.match(%r{/passwords/([^/\s"']+)/edit}) || email_body.match(%r{passwords/([^/\s"']+)/edit})
  raise "Could not find password reset token in email! Email body: #{email_body[0..500]}" unless token_match

  @password_reset_token = token_match[1]
end

Then("I should still be on the password reset request page") do
  expect(page).to have_current_path(new_password_path)
end

Then("I should still be on the password reset edit page") do
  expect(page).to have_current_path(edit_password_path(@password_reset_token))
end

Then("I should be able to login with email {string} and password {string}") do |email, password|
  visit new_session_path
  fill_in "Email address", with: email
  fill_in "Password", with: password
  click_button "Login"
  expect(page).not_to have_current_path(new_session_path, wait: 10)
  expect(page).to have_link("Logout", wait: 5)
end

Then("the password field should be invalid") do
  password_field = find_field("New password")
  expect(password_field[:required]).to be_truthy
  expect(password_field[:type]).to eq("password")
end

Then("the email field should be invalid on password reset page") do
  email_field = find_field("Email address")
  expect(email_field[:type]).to eq("email")
  # Since we're not using HTML5 required, check that the alert message is shown
  expect(page).to have_css("#alert", text: "Email address is required")
end

Then("I should see an error message") do
  # Check for Rails validation errors - the error message container
  has_red_box = page.has_css?(".bg-red-50", wait: 5)
  has_red_text = page.has_css?(".text-red-700", wait: 5)
  expect(has_red_box || has_red_text).to be_truthy
end

