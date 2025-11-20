Feature: Searching for locations
  As a user
  I want to search for locations by name
  So that I can quickly find accessible places in Evanston

  Background:
    Given that the following users exists:
      | email_address                        | password       |
      | isabellayan2027@u.northwestern.edu   | Password!12345 |
    And I am logged in as "isabellayan2027@u.northwestern.edu"
    Given the following locations exist:
      | name                     | address              | city     | state | zip     | country | user_email |
      | Evanston Public Library  | 1703 Orrington Ave   | Evanston | IL    | 60201   | USA     | isabellayan2027@u.northwestern.edu |
      | Trader Joe's Evanston    | 1211 Chicago Ave     | Evanston | IL    | 60202   | USA     | isabellayan2027@u.northwestern.edu |


  Scenario: Happy - searching returns matching locations
    When I visit the search page
    And I fill in "Search locations" with "Library"
    And I press "Search"
    Then I should see "Evanston Public Library"
    And I should not see "Trader Joe's Evanston"

  Scenario: Sad - searching returns nothing
    When I visit the search page
    And I fill in "Search locations" with "XYZPLACE"
    And I press "Search"
    Then I should see "No locations found."
