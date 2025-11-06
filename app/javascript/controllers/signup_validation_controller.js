import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "emailInput",
    "emailFeedback",
    "passwordInput",
    "passwordConfirmationInput",
    "passwordLengthFeedback",
    "passwordLowercaseFeedback",
    "passwordUppercaseFeedback",
    "passwordDigitFeedback",
    "passwordSpecialCharFeedback",
    "passwordMatchFeedback",
    "submitButton"
  ]

  connect() {
    this.validate() // Run validation on connect to set initial button state and feedback
  }

  validate() {
    this.validateEmail()
    this.validatePassword()
    this.validatePasswordConfirmation()
    this.updateSubmitButtonState()
  }

  validateEmail() {
    const email = this.emailInputTarget.value
    const isValid = /.+@.+\..+/.test(email)
    this.toggleIconFeedback(this.emailFeedbackTarget, isValid)
    return isValid
  }

  validatePassword() {
    const password = this.passwordInputTarget.value
    const minLength = password.length >= 12
    const hasLowercase = /[a-z]/.test(password)
    const hasUppercase = /[A-Z]/.test(password)
    const hasDigit = /\d/.test(password)
    const hasSpecialChar = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~]/.test(password)

    this.toggleIconFeedback(this.passwordLengthFeedbackTarget, minLength)
    this.toggleIconFeedback(this.passwordLowercaseFeedbackTarget, hasLowercase)
    this.toggleIconFeedback(this.passwordUppercaseFeedbackTarget, hasUppercase)
    this.toggleIconFeedback(this.passwordDigitFeedbackTarget, hasDigit)
    this.toggleIconFeedback(this.passwordSpecialCharFeedbackTarget, hasSpecialChar)

    return minLength && hasLowercase && hasUppercase && hasDigit && hasSpecialChar
  }

  validatePasswordConfirmation() {
    const password = this.passwordInputTarget.value
    const confirmation = this.passwordConfirmationInputTarget.value
    const isMatch = password === confirmation && password !== ''

    this.toggleIconFeedback(this.passwordMatchFeedbackTarget, isMatch)
    return isMatch
  }

  updateSubmitButtonState() {
    const isEmailValid = this.validateEmail()
    const isPasswordStrong = this.validatePassword()
    const isPasswordConfirmed = this.validatePasswordConfirmation()

    this.submitButtonTarget.disabled = !(isEmailValid && isPasswordStrong && isPasswordConfirmed)
  }

  toggleIconFeedback(element, isValid) {
    if (isValid) {
      element.classList.remove('text-red-500')
      element.classList.add('text-green-500')
      element.textContent = '✓' // Checkmark
    } else {
      element.classList.remove('text-green-500')
      element.classList.add('text-red-500')
      element.textContent = '✗' // X mark
    }
  }
}
