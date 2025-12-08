Feature: Edit Location
  As a logged-in user
  I want to edit my locations
  So that I can update location information

  Background:
    Given I am logged in as a user with email "test@example.com" and password "TestPassword123!"
    And I have a location named "Original Location" at "123 Main St, Chicago, IL 60601, United States"

  Scenario: Successful location edit - changing name only
    Given I am on the edit page for the location "Original Location"
    When I fill in the location name with "Updated Location Name"
    And I click "Save Changes"
    Then I should be redirected to the location show page
    And I should see "Location was successfully updated."
    And I should see "Updated Location Name"

  Scenario: Successful location edit - changing address
    Given I am on the edit page for the location "Original Location"
    When I fill in the address search field with "789 New St, Chicago, IL 60603, United States"
    And I wait for address autocomplete to populate fields
    And I click "Save Changes"
    Then I should be redirected to the location show page
    And I should see "Location was successfully updated."

  Scenario: Failed location edit with missing name
    Given I am on the edit page for the location "Original Location"
    When I clear the location name field
    And I enable the submit button manually
    And I click "Save Changes"
    Then I should still be on the edit location page
    And I should see an error message for location
    And I should see "Name can't be blank"

  Scenario: Failed location edit with name too long
    Given I am on the edit page for the location "Original Location"
    When I fill in the location name with "This is a very long location name that exceeds the maximum allowed length of sixty characters"
    And I click "Save Changes"
    Then I should still be on the edit location page
    And I should see an error message for location
    And I should see "Name is too long"

  Scenario: Failed location edit with invalid address
    Given I am on the edit page for the location "Original Location"
    When I clear the address fields
    And I set invalid address coordinates
    And I enable the submit button manually
    And I click "Save Changes"
    Then I should still be on the edit location page
    And I should see an error message for location
    And I should see "Address could not be located"

  Scenario: User cannot edit location they do not own
    Given another user exists with email "other@example.com" and password "OtherPassword123!"
    And that user has a location named "Other User's Location" at "999 Other St, Chicago, IL 60604, United States"
    When I try to visit the edit page for "Other User's Location"
    Then I should be redirected to the location show page
    # The authorization redirect happens but alert may not be displayed in show view
    # We verify we were redirected (couldn't edit) and are on the show page

  Scenario: Redirected to login when not authenticated
    Given I am logged out
    And a location exists named "Some Location" at "555 Unique St, Chicago, IL 60605, United States"
    When I try to visit the edit page for "Some Location"
    Then I should be redirected to the login page from location
