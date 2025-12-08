Feature: User Signup
  As a visitor
  I want to create a new account
  So that I can access the application and create locations and reviews

  Scenario: Successful signup with valid credentials
    Given I am on the signup page
    When I fill in "Username" with "testuser"
    And I fill in "Email address" with "newuser@example.com"
    And I fill in "Password" with "TestPassword123!"
    And I fill in "Password confirmation" with "TestPassword123!"
    And I click "Sign Up"
    Then I should be redirected to the login page
    And I should see "Account created successfully! Please sign in."

  Scenario: Failed signup with missing username
    Given I am on the signup page
    When I fill in "Email address" with "newuser@example.com"
    And I fill in "Password" with "TestPassword123!"
    And I fill in "Password confirmation" with "TestPassword123!"
    And I click "Sign Up"
    Then I should still be on the signup page
    And I should see an error message
    And the username field should be invalid

  Scenario: Failed signup with missing email
    Given I am on the signup page
    When I fill in "Username" with "testuser"
    And I fill in "Password" with "TestPassword123!"
    And I fill in "Password confirmation" with "TestPassword123!"
    And I click "Sign Up"
    Then I should still be on the signup page
    And I should see an error message

  Scenario: Failed signup with missing password
    Given I am on the signup page
    When I fill in "Username" with "testuser"
    And I fill in "Email address" with "newuser@example.com"
    And I fill in "Password confirmation" with "TestPassword123!"
    And I click "Sign Up"
    Then I should still be on the signup page
    And I should see an error message

  Scenario: Failed signup with password too short
    Given I am on the signup page
    When I fill in "Username" with "testuser"
    And I fill in "Email address" with "newuser@example.com"
    And I fill in "Password" with "Short1!"
    And I fill in "Password confirmation" with "Short1!"
    And I click "Sign Up"
    Then I should still be on the signup page
    And I should see "must be at least 12 characters long"

  Scenario: Failed signup with password missing complexity requirements
    Given I am on the signup page
    When I fill in "Username" with "testuser"
    And I fill in "Email address" with "newuser@example.com"
    And I fill in "Password" with "alllowercase123"
    And I fill in "Password confirmation" with "alllowercase123"
    And I click "Sign Up"
    Then I should still be on the signup page
    And I should see "must include at least one lowercase letter, one uppercase letter, one digit, and one special character"

  Scenario: Failed signup with password confirmation mismatch
    Given I am on the signup page
    When I fill in "Username" with "testuser"
    And I fill in "Email address" with "newuser@example.com"
    And I fill in "Password" with "TestPassword123!"
    And I fill in "Password confirmation" with "DifferentPass123!"
    And I click "Sign Up"
    Then I should still be on the signup page
    And I should see "doesn't match Password"

  Scenario: Failed signup with duplicate email
    Given a user exists with email "existing@example.com" and password "TestPassword123!"
    And I am on the signup page
    When I fill in "Username" with "testuser"
    And I fill in "Email address" with "existing@example.com"
    And I fill in "Password" with "TestPassword123!"
    And I fill in "Password confirmation" with "TestPassword123!"
    And I click "Sign Up"
    Then I should still be on the signup page
    And I should see "has already been taken"

