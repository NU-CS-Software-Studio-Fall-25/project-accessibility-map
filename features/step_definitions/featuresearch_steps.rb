# frozen_string_literal: true

Given("the following features exist:") do |table|
  table.hashes.each do |row|
    Feature.create!(
      feature: row["feature"],
      feature_category: row["feature_category"],
    )
  end
end

Given("{string} has features: {string}") do |location_name, feature_list|
  location = Location.find_by!(name: location_name)
  feature_names = feature_list.split(",").map(&:strip)
  features = Feature.where(feature: feature_names)
  location.features << features
end

When("I open the feature filter") do
  find("summary", text: "Filter by features").click
end

When("I check {string}") do |feature_name|
  details = find("details", match: :first)
  unless details[:open]
    details.find("summary").click
  end
  label = details.find("label", text: feature_name, match: :first)
  checkbox = label.find("input[type='checkbox']", visible: :all)
  checkbox.check
end

Then("I should see {string} if nothing matches") do |string|
  expect(page).to(have_content(string))
end
