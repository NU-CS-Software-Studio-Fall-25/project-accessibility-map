Feature: User Login
  As a user
  I want to log in to my account
  So that I can access my profile and create locations and reviews

  Background:
    Given a user exists with email "test@example.com" and password "TestPassword123!"

  Scenario: Successful login with valid credentials
    Given I am on the login page
    When I fill in "Email address" with "test@example.com"
    And I fill in "Password" with "TestPassword123!"
    And I click "Login"
    Then I should be redirected to the home page
    And I should see that I am logged in

  Scenario: Failed login with incorrect email
    Given I am on the login page
    When I fill in "Email address" with "wrong@example.com"
    And I fill in "Password" with "TestPassword123!"
    And I click "Login"
    Then I should see "Incorrect email or password."
    And I should still be on the login page

  Scenario: Failed login with incorrect password
    Given I am on the login page
    When I fill in "Email address" with "test@example.com"
    And I fill in "Password" with "WrongPassword123!"
    And I click "Login"
    Then I should see "Incorrect email or password."
    And I should still be on the login page

  Scenario: Failed login with empty email
    Given I am on the login page
    When I fill in "Password" with "TestPassword123!"
    And I click "Login"
    Then I should still be on the login page
    And the email field should be invalid

  Scenario: Failed login with empty password
    Given I am on the login page
    When I fill in "Email address" with "test@example.com"
    And I click "Login"
    Then I should still be on the login page
    And the password field should be invalid
