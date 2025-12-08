Feature: Create Location
  As a logged-in user
  I want to create a new location
  So that I can share accessible locations with others

  Background:
    Given I am logged in as a user with email "test@example.com" and password "TestPassword123!"

  Scenario: Successful location creation with all required fields
    Given I am on the new location page
    When I fill in the location name with "Test Coffee Shop"
    And I fill in the address search field with "123 Main St, Chicago, IL 60601, United States"
    And I wait for address autocomplete to populate fields
    And I click "Add Location"
    Then I should be redirected to the location show page
    And I should see "Location was successfully created."
    And I should see "Test Coffee Shop"

  Scenario: Successful location creation with different address
    Given I am on the new location page
    When I fill in the location name with "Another Place"
    And I fill in the address search field with "456 Oak Ave, Chicago, IL 60602, United States"
    And I wait for address autocomplete to populate fields
    And I click "Add Location"
    Then I should be redirected to the location show page
    And I should see "Location was successfully created."

  Scenario: Failed location creation with missing name
    Given I am on the new location page
    When I fill in the address search field with "123 Main St, Chicago, IL 60601, United States"
    And I wait for address autocomplete to populate fields
    And I click "Add Location"
    Then I should still be on the new location page
    And I should see an error message for location
    And I should see "Name can't be blank"

  Scenario: Failed location creation with missing address
    Given I am on the new location page
    When I fill in the location name with "Test Location"
    # Enable the submit button even though address isn't filled (to test validation)
    And I enable the submit button manually
    And I click "Add Location"
    Then I should still be on the new location page
    And I should see an error message for location
    And I should see "Address could not be located"

  Scenario: Failed location creation with name too long
    Given I am on the new location page
    When I fill in the location name with "This is a very long location name that exceeds the maximum allowed length of sixty characters"
    And I fill in the address search field with "123 Main St, Chicago, IL 60601, United States"
    And I wait for address autocomplete to populate fields
    And I click "Add Location"
    Then I should still be on the new location page
    And I should see an error message for location
    And I should see "Name is too long"

  Scenario: Redirected to login when not authenticated
    Given I am logged out
    When I visit the new location page
    Then I should be redirected to the login page from location

  Scenario: Successful location creation with features selected
    Given I am on the new location page
    When I fill in the location name with "Accessible Restaurant"
    And I fill in the address search field with "456 Oak Ave, Chicago, IL 60602, United States"
    And I wait for address autocomplete to populate fields
    And I select at least one feature
    And I click "Add Location"
    Then I should be redirected to the location show page
    And I should see "Location was successfully created."

