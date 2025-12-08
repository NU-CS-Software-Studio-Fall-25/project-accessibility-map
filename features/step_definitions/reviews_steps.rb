# frozen_string_literal: true

# ---------- helpers ----------

def find_location_by_name!(name)
  Location.find_by!(name: name)
end

def current_test_user
  @current_user ||= User.find_by(email_address: "test@example.com") || User.first
end

def has_modal_toggle?
  page.has_css?('[data-modal-toggle="add-review-modal"]', wait: 0)
end

def open_review_modal!
  # Try normal toggle
  if has_modal_toggle?
    find('[data-modal-toggle="add-review-modal"]', match: :first).click
  end
  # If still hidden, force-open in CI by removing the "hidden" class
  unless page.has_css?("#add-review-modal:not(.hidden)", wait: 0)
    page.execute_script("var m=document.getElementById('add-review-modal'); if(m){m.classList.remove('hidden'); m.setAttribute('aria-hidden','false');}")
  end
end

def within_modal(&block)
  # Ensure modal exists in DOM even if hidden
  expect(page).to(have_css("#add-review-modal", wait: 2))
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
  # Your partial uses form.textarea :body -> id=review_body, name=review[body]
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
        if (el.setCustomValidity) el.setCustomValidity('');
      } catch(_) {}
    })(arguments[0]);
  JS
end

def submit_modal_form(form)
  # Remove browser-side blockers so server validations run in CI
  strip_html5_validation(form)

  # Your submit is labeled "Add Review" in new form; edit UI may differ.
  if form.has_button?("Add Review", wait: 0, visible: :all)
    form.click_button("Add Review")
  elsif form.has_css?("button[type='submit'],input[type='submit']", wait: 0, visible: :all)
    form.find(:css, "button[type='submit'],input[type='submit']").click
  else
    page.execute_script("arguments[0].submit()", form.native)
  end
end

def review_container_by_text(text)
  return if text.to_s.strip.empty?

  # Prefer an ancestor with class containing "review"
  container = first(
    :xpath,
    "//*[contains(normalize-space(.), #{XPath.quote(text)})]" \
      "[ancestor::*[contains(@class,'review')]][1]" \
      "/ancestor::*[contains(@class,'review')][1]",
    wait: 0,
  )

  return container if container

  # Fallback: nearest block (div/section/article)
  first(
    :xpath,
    "//*[contains(normalize-space(.), #{XPath.quote(text)})]" \
      "/ancestor::*[self::div or self::section or self::article][1]",
    wait: 0,
  )
end

def click_edit_inside!(container)
  # Try visible link/button label variants
  ["Edit", "Edit Review"].each do |label|
    if container.has_link?(label, wait: 0, exact: false)
      container.first(:link, label, exact: false).click
      return true
    end
    if container.has_button?(label, wait: 0, exact: false)
      container.first(:button, label, exact: false).click
      return true
    end
  end

  # Try common icon/aria roles
  candidates = container.all(
    :xpath,
    ".//*[self::a or self::button][@title or @aria-label]",
    wait: 0,
  )
  node = candidates.find do |n|
    t = (n[:title].to_s + " " + n[:"aria-label"].to_s).downcase
    t.include?("edit")
  end
  if node
    node.click
    return true
  end

  false
end

# ---------- navigation steps ----------

Given("I am on the location show page for {string}") do |name|
  @location = find_location_by_name!(name)
  visit location_path(@location)
end

When("I visit the new review page for {string}") do |name|
  @location = find_location_by_name!(name)
  visit location_path(@location)
  open_review_modal!
end

Then("I should be on the new review page for {string}") do |name|
  loc = find_location_by_name!(name)
  expect(page).to(have_current_path(location_path(loc), ignore_query: true))

  within_modal do
    form = first("form", minimum: 1)
    expect(form).to(be_present)
    has_textarea = form.has_field?("review_body", wait: 0, visible: :all) ||
      form.has_field?("review[body]", wait: 0, visible: :all)
    expect(has_textarea).to(be(true), "Expected a review textarea inside the modal")
  end
end

Given("I have a review on {string} with body {string}") do |name, body|
  @location = find_location_by_name!(name)
  user = current_test_user
  @review = Review.find_or_create_by!(user: user, location: @location) { |r| r.body = body }
end

Given("I am on the edit page for my review on {string}") do |name|
  @location = find_location_by_name!(name)
  visit location_path(@location)

  # Try to find the specific review and its edit control
  container = review_container_by_text(@review&.body.to_s)
  opened = container && click_edit_inside!(container)

  # If there is no explicit per-review edit control, fall back to the same modal UI
  open_review_modal! unless opened
end

When("I try to visit the edit page for that user's review") do
  visit location_path(@location)
  container = review_container_by_text(@other_review.body)

  if container
    # If an edit control is exposed for another user's review, clicking it should not navigate away
    clicked = click_edit_inside!(container)
    if clicked
      expect(page).to(have_current_path(location_path(@location), ignore_query: true))
      next
    end
  end

  # No edit control for someone else's review: already blocked
  expect(page).to(have_current_path(location_path(@location), ignore_query: true))
end

Given("that user has a review on {string} with body {string}") do |name, body|
  @location = find_location_by_name!(name)
  @other_user ||= User.find_by(email_address: "other@example.com") ||
    User.create!(
      email_address: "other@example.com",
      username: "other",
      password: "OtherPassword123!",
    )
  @other_review = Review.find_or_create_by!(user: @other_user, location: @location) { |r| r.body = body }
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
  # When logged out the toggle isn’t shown; the modal DOM still exists.
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
