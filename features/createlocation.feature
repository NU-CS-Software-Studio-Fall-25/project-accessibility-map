Feature: Creating a location 
  As a user
  I want to create a new location 
  So that I can review a place that suits my needs 

  Background:
    Given that the following users exists:
      | email_address                      | password       |
      | isabellayan2027@u.northwestern.edu | Password!12345 |

    And the following features exist:
      | feature                  | feature_category |
      | Wheelchair accessible    | Accessibility    |
      | Gender neutral restrooms | Accessibility    |
      | Quiet study space        | Environment      |


    And I am logged in as "isabellayan2027@u.northwestern.edu"

  Scenario: Happy - create a new location successfully
    When I visit the new location page
    And I fill in "location_name" with "Evanston Public Library"
    And I fill in "location_address" with "1703 Orrington Ave"
    And I fill in "location_city" with "Evanston"
    And I select "Illinois" from "State"
    And I fill in "location_zip" with "60201"
    And I select "United States" from "Country"
    And I check feature "Wheelchair accessible"
    And I press "Add Location"
    Then I should see "Evanston Public Library"
    Then I should see "Wheelchair accessible"


