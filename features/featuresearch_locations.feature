Feature: Searching for locations by features
  As a user
  I want to filter locations by accessibility features
  So that I can find places that meet my needs

  Background:
    Given that the following users exist:
      | email_address                      | password       | username |
      | isabellayan2027@u.northwestern.edu | Password!12345 | i1234    |


    And I am logged in as "isabellayan2027@u.northwestern.edu"

    And the following features exist:
      | feature                 | feature_category       |
      | Wheelchair accessible   | Physical Accessibility |
      | Automatic doors         | Physical Accessibility |
      | Vegetarian              | Food & Diet            |

    And the following locations exist:
      | name                    | address            | city     | state | zip   | country | user_email                               |
      | Evanston Public Library | 1703 Orrington Ave | Evanston | IL    | 60201 | USA     | isabellayan2027@u.northwestern.edu       |
      | Trader Joe's Evanston   | 1211 Chicago Ave   | Evanston | IL    | 60202 | USA     | isabellayan2027@u.northwestern.edu       |

    And "Evanston Public Library" has features: "Wheelchair accessible, Automatic doors"
    And "Trader Joe's Evanston" has features: "Automatic doors"


  Scenario: Happy - filter by one feature
    When I visit the search page
    And I open the feature filter modal
    And I check "Wheelchair accessible"
    And I press "Search"
    Then I should see "Evanston Public Library"
    And I should not see "Trader Joe's Evanston"


  Scenario: Happy - filter by two features
    When I visit the search page
    And I open the feature filter modal
    And I check "Automatic doors"
    And I check "Wheelchair accessible"
    And I press "Search"
    Then I should see "Evanston Public Library"
    And I should not see "Trader Joe's Evanston"


  Scenario: Sad - no locations match the selected features
    When I visit the search page
    And I open the feature filter modal
    And I check "Vegetarian"
    And I press "Search"
    Then I should see "No locations found." 