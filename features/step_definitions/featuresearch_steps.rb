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

When("I open the feature filter modal") do
  click_on "Filters"   # adjust to your button text
end

When("I check {string}") do |feature_name|
  within("div[role='dialog']") do   
    label = find("label", text: feature_name, match: :first)
    label.click
  end
end