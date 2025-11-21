# features/step_definitions/search_steps.rb
Given('the following users exists:') do |table|
  table.hashes.each do |row|
    User.create!(
      email_address: row["email_address"],
      password: row["password"]
    )   
  end
end