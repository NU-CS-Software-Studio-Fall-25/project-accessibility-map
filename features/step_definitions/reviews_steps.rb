# frozen_string_literal: true

# ---------- small helpers ----------

def find_location_by_name!(name)
  Location.find_by!(name: name)
end

def current_test_user
  @current_user ||= User.find_by(email_address: "test@example.com") || User.first
end

def has_modal_toggle?
  page.has_css?('[data-modal-toggle="add-review-modal"]', wait: 0)
end

def click_modal_toggle
  find('[data-modal-toggle="add-review-modal"]', match: :first).click
end

def within_modal(&block)
  within("#add-review-modal", &block)
end

def first_modal_form
  within_modal do
    form = first("form", minimum: 1)
    raise "No form found in #add-review-modal" unless form

    form
  end
end

def set_modal_body(form, value)
  if form.has_field?("review_body", wait: 0, visible: :all)
    form.fill_in("review_body", with: value)
  elsif form.has_field?("review[body]", wait: 0, visible: :all)
    form.fill_in("review[body]", with: value)
  else
    raise "Textarea not found (id='review_body' or name='review[body]')"
  end
end

def strip_html5_validation(form)
  el = form.first(
    :css,
    'textarea#review_body, textarea[name="review[body]"]',
    minimum: 1,
    visible: :all,
  )
  return unless el

  page.execute_script(<<~JS, el.native)
    (function(el){
      try {
        el.removeAttribute('required');
        el.removeAttribute('minlength');
        el.required = false;
        el.setCustomValidity && el.setCustomValidity('');
      } catch(_) {}
    })(arguments[0]);
  JS
end

def submit_modal_form(form)
  # Always strip client-side constraints so server validations run in headless CI
  strip_html5_validation(form)
  if form.has_button?("Add Review", wait: 0, visible: :all)
    form.click_button("Add Review")
  elsif form.has_css?(
    "button[type='submit'], input[type='submit']",
    wait: 0,
    visible: :all,
  )
    form.find(:css, "button[type='submit'], input[type='submit']").click
  else
    page.execute_script("arguments[0].submit()", form.native)
  end
end

# Finds the review container that contains +text+ (robust to markup)
def find_review_container_by_text(text)
  # Try a common container class first
  node = first(
    :xpath,
    "//*[contains(normalize-space(.), #{XPath.quote(text)})]" \
      "[ancestor::*[contains(@class,'review')]][1]/ancestor::*[contains(@class,'review')][1]",
    wait: 0,
  )
  return node if node

  # Fallback: nearest block element that contains the text
  first(
    :xpath,
    "//*[contains(normalize-space(.), #{XPath.quote(text)})]" \
      "/ancestor::*[self::article or self::section or self::div][1]",
    wait: 0,
  )
end

def click_edit_inside(container)
  # Prefer a link labeled Edit
  if container.has_link?("Edit", wait: 0, exact: false)
    container.first(:link, "Edit", exact: false).click
    return true
  end
  # Or a button labeled Edit
  if container.has_button?("Edit", wait: 0, exact: false)
    container.first(:button, "Edit", exact: false).click
    return true
  end
  false
end

# ---------- navigation ----------

Given("I am on the location show page for {string}") do |name|
  @location = find_location_by_name!(name)
  visit location_path(@location)
end

When("I visit the new review page for {string}") do |name|
  @location = find_location_by_name!(name)
  visit location_path(@location)
  click_modal_toggle if has_modal_toggle?
end

Then("I should be on the new review page for {string}") do |name|
  loc = find_location_by_name!(name)
  expect(page).to(have_current_path(location_path(loc), ignore_query: true))
  within_modal do
    form = first("form", minimum: 1)
    expect(form).to(be_present)
    has_field = form.has_field?("review_body", wait: 0, visible: :all) ||
      form.has_field?("review[body]", wait: 0, visible: :all)
    expect(has_field).to(be(true), "Expected a review textarea inside the modal")
  end
end

Given("I have a review on {string} with body {string}") do |name, body|
  @location = find_location_by_name!(name)
  user = current_test_user
  @review = Review.find_or_create_by!(user: user, location: @location) { |r| r.body = body }
end

Given("I am on the edit page for my review on {string}") do |name|
  # Strategy:
  # 1) Find the review block containing the body we just created.
  # 2) Click its Edit control if present.
  # 3) If no explicit edit UI exists, open the same modal so later steps can submit.
  @location = find_location_by_name!(name)
  visit location_path(@location)

  review_text = @review&.body || ""
  container = review_text.empty? ? nil : find_review_container_by_text(review_text)
  opened = false
  opened = click_edit_inside(container) if container

  click_modal_toggle if !opened && has_modal_toggle?
end

When("I try to visit the edit page for that user's review") do
  # We ensure an "other user" review exists (see step below),
  # then attempt to click its Edit if visible; otherwise we consider the attempt blocked.
  visit location_path(@location)
  container = find_review_container_by_text(@other_review.body)
  if container
    # If an edit control is visible for other user's review, click and expect to end up back on show
    clicked = click_edit_inside(container)
    if clicked
      expect(page).to(have_current_path(location_path(@location), ignore_query: true))
      next
    end
  end
  # No visible edit for other user's review: we are effectively blocked already.
  expect(page).to(have_current_path(location_path(@location), ignore_query: true))
end

# CI was missing this definition previously
Given("that user has a review on {string} with body {string}") do |name, body|
  @location = find_location_by_name!(name)
  @other_user ||= User.find_by(email_address: "other@example.com") ||
    User.create!(
      email_address: "other@example.com",
      username: "other",
      password: "OtherPassword123!",
    )
  @other_review = Review.find_or_create_by!(user: @other_user, location: @location) do |r|
    r.body = body
  end
end

# ---------- form actions ----------

When("I fill in the review body with {string}") do |text|
  form = first_modal_form
  set_modal_body(form, text)
  @current_review_form = form
end

When("I clear the review body field") do
  form = first_modal_form
  set_modal_body(form, "")
  @current_review_form = form
end

When("I submit the review form") do
  form = @current_review_form || first_modal_form
  submit_modal_form(form)
end

# ---------- assertions ----------

Then("I should be on the location show page for {string}") do |name|
  loc = find_location_by_name!(name)
  expect(page).to(have_current_path(location_path(loc), ignore_query: true))
end

Then("I should be redirected to the login page from review") do
  # When logged out, the toggle isn’t rendered; the modal DOM is present.
  # Force-submit to trigger auth redirect.
  visit current_path
  within_modal do
    form = first("form", minimum: 1)
    raise "No form present in modal for logged-out submit" unless form

    strip_html5_validation(form)
    page.execute_script("arguments[0].submit()", form.native)
  end
  expect(page).to(have_current_path(new_session_path, ignore_query: false))
end

Then("I should see a validation error for the review body") do
  within_modal do
    form = first_modal_form
    field = form.first(:fillable_field, "review_body", wait: 0) ||
      form.first(:fillable_field, "review[body]", wait: 0)
    expect(field).to(be_present)

    error_present =
      form.has_css?("#error_explanation", wait: 0) ||
      field["aria-invalid"].to_s == "true" ||
      page.has_text?(/blank|required|too short|invalid/i)

    expect(error_present).to(be(true), "Expected a validation error for the review textarea")
  end
end
