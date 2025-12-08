Feature: Password Reset
  As a user who forgot their password
  I want to reset my password
  So that I can regain access to my account

  Background:
    Given a user exists with email "user@example.com" and password "OldPassword123!"

  Scenario: Successful password reset request
    Given I am on the password reset request page
    When I fill in "Email address" with "user@example.com"
    And I click "Request password reset"
    Then I should be redirected to the login page
    And I should see "Password reset instructions sent (if user with that email address exists)."

  Scenario: Password reset request with non-existent email
    Given I am on the password reset request page
    When I fill in "Email address" with "nonexistent@example.com"
    And I click "Request password reset"
    Then I should be redirected to the login page
    And I should see "Password reset instructions sent (if user with that email address exists)."

  Scenario: Successful password reset with valid token
    Given I am on the password reset request page
    When I fill in "Email address" with "user@example.com"
    And I click "Request password reset"
    And I extract the password reset token from the email
    And I visit the password reset edit page with the token
    When I fill in "New password" with "NewPassword123!"
    And I fill in "Confirm new password" with "NewPassword123!"
    And I click "Save password"
    Then I should be redirected to the login page
    And I should see "Password has been reset."
    And I should be able to login with email "user@example.com" and password "NewPassword123!"

  Scenario: Failed password reset with mismatched passwords
    Given I am on the password reset request page
    When I fill in "Email address" with "user@example.com"
    And I click "Request password reset"
    And I extract the password reset token from the email
    And I visit the password reset edit page with the token
    When I fill in "New password" with "NewPassword123!"
    And I fill in "Confirm new password" with "DifferentPass123!"
    And I click "Save password"
    Then I should see "Passwords did not match."
    And I should still be on the password reset edit page

  Scenario: Failed password reset with password too short
    Given I am on the password reset request page
    When I fill in "Email address" with "user@example.com"
    And I click "Request password reset"
    And I extract the password reset token from the email
    And I visit the password reset edit page with the token
    When I fill in "New password" with "Short1!"
    And I fill in "Confirm new password" with "Short1!"
    And I click "Save password"
    Then I should still be on the password reset edit page
    And I should see an error message

  Scenario: Failed password reset with password missing complexity
    Given I am on the password reset request page
    When I fill in "Email address" with "user@example.com"
    And I click "Request password reset"
    And I extract the password reset token from the email
    And I visit the password reset edit page with the token
    When I fill in "New password" with "alllowercase123456"
    And I fill in "Confirm new password" with "alllowercase123456"
    And I click "Save password"
    Then I should still be on the password reset edit page
    And I should see an error message

  Scenario: Failed password reset with invalid token
    When I visit the password reset edit page with token "invalid-token-12345"
    Then I should be redirected to the password reset request page
    And I should see "Password reset link is invalid or has expired."

  Scenario: Failed password reset with empty password
    Given I am on the password reset request page
    When I fill in "Email address" with "user@example.com"
    And I click "Request password reset"
    And I extract the password reset token from the email
    And I visit the password reset edit page with the token
    When I fill in "Confirm new password" with "NewPassword123!"
    And I click "Save password"
    Then I should still be on the password reset edit page
    And the password field should be invalid

  Scenario: Failed password reset request with empty email
    Given I am on the password reset request page
    When I click "Request password reset"
    Then I should still be on the password reset request page
    And I should see "Email address is required."
    And the email field should be invalid on password reset page
