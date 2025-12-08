Feature: Add/Edit Review
  As a logged-in user
  I want to add and edit reviews on a location
  So that I can share and update my feedback

  Background:
    Given I am logged in as a user with email "test@example.com" and password "Password!123"
    And a location exists named "Reviewable Place" at "123 Main St, Evanston, IL 60201, USA"
    And I am on the location show page for "Reviewable Place"

  Scenario: Successful review creation
    When I visit the new review page for "Reviewable Place"
    And I fill in the review body with "Great accessibility and friendly staff."
    And I submit the review form
    Then I should be on the location show page for "Reviewable Place"
    And I should see "Review was successfully created"
    And I should see "Great accessibility and friendly staff."

  Scenario: Successful review edit
    Given I have a review on "Reviewable Place" with body "Good ramps."
    And I am on the edit page for my review on "Reviewable Place"
    When I fill in the review body with "Good ramps, signage could be clearer."
    And I click "Save Changes"
    Then I should be on the location show page for "Reviewable Place"
    And I should see "Review was successfully updated"
    And I should see "Good ramps, signage could be clearer."

  Scenario: Failed review creation with missing body
    When I visit the new review page for "Reviewable Place"
    And I clear the review body field
    And I enable the submit button manually
    And I submit the review form
    Then I should be on the new review page for "Reviewable Place"
    And I should see a validation error for the review body

  Scenario: User cannot edit someone else's review
    Given another user exists with email "other@example.com" and password "OtherPassword123!"
    And that user has a review on "Reviewable Place" with body "Fantastic!"
    When I try to visit the edit page for that user's review
    Then I should be on the location show page for "Reviewable Place"

  Scenario: Redirected to login when not authenticated
    Given I am logged out
    When I visit the new review page for "Reviewable Place"
    Then I should be redirected to the login page from review