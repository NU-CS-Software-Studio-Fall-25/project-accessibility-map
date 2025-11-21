Feature: Searching for locations using text and features
  As a user
  I want to search by name and filter by features
  So that I can quickly find locations that match both criteria

  Background:
    Given that the following users exists:
      | email_address                        | password       |
      | isabellayan2027@u.northwestern.edu   | Password!12345 |
    And I am logged in as "isabellayan2027@u.northwestern.edu"

    And the following features exist:
      | feature                 | feature_category       |
      | Wheelchair accessible   | Physical Accessibility |
      | Automatic doors         | Physical Accessibility |
      | Vegetarian              | Food & Diet            |

    And the following locations exist:
      | name                     | address              | city     | state | zip     | country | user_email |
      | Evanston Public Library  | 1703 Orrington Ave   | Evanston | IL    | 60201   | USA     | isabellayan2027@u.northwestern.edu |
      | Trader Joe's Evanston    | 1211 Chicago Ave     | Evanston | IL    | 60202   | USA     | isabellayan2027@u.northwestern.edu |

    And "Evanston Public Library" has features: "Wheelchair accessible, Automatic doors"
    And "Trader Joe's Evanston" has features: "Automatic doors"


  Scenario: Happy - text query AND feature both match
    When I visit the search page
    And I fill in "Search locations" with "Library"
    And I check "Wheelchair accessible"
    And I press "Search"
    Then I should see "Evanston Public Library"
    And I should not see "Trader Joe's Evanston"


  Scenario: Sad - text matches but features eliminate all results
    When I visit the search page
    And I fill in "Search locations" with "Evanston"
    And I check "Vegetarian"
    And I press "Search"
    Then I should see "No locations found."


  Scenario: Happy - feature filters narrow down text-matched results
    When I visit the search page
    And I fill in "Search locations" with "Evanston"
    And I check "Wheelchair accessible"
    And I press "Search"
    Then I should see "Evanston Public Library"
    And I should not see "Trader Joe's Evanston"


  Scenario: Happy - text ignored when empty, but features filter works
    When I visit the search page
    And I check "Wheelchair accessible"
    And I press "Search"
    Then I should see "Evanston Public Library"
    And I should not see "Trader Joe's Evanston"
