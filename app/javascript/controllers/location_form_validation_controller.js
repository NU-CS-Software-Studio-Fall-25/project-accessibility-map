import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 
    "nameInput", "nameFeedback",
    "addressInput", "addressFeedback",
    "cityInput", "cityFeedback",
    "stateInput", "stateFeedback",
    "countryInput", "countryFeedback",
    "zipInput", "zipFeedback", 
    "submitButton" 
  ]

  connect() {
    this.validate()
  }

  validate() {
    let isFormValid = true

    // Validate Name
    isFormValid = this.validatePresence(this.nameInputTarget, this.nameFeedbackTarget, "Name cannot be empty.") && isFormValid

    // Validate Address
    isFormValid = this.validatePresence(this.addressInputTarget, this.addressFeedbackTarget, "Address cannot be empty.") && isFormValid

    // Validate City
    isFormValid = this.validatePresence(this.cityInputTarget, this.cityFeedbackTarget, "City cannot be empty.") && isFormValid

    // Validate State
    isFormValid = this.validatePresence(this.stateInputTarget, this.stateFeedbackTarget, "State cannot be empty.") && isFormValid

    // Validate Country
    isFormValid = this.validatePresence(this.countryInputTarget, this.countryFeedbackTarget, "Country cannot be empty.") && isFormValid

    // Validate Zip Code (conditional on country)
    if (this.countryInputTarget.value === "United States") {
      this.zipFeedbackTarget.hidden = false;
      const zip = this.zipInputTarget.value.trim();

      if (zip === "") {
        this.zipInputTarget.classList.add("border-red-500");
        this.zipInputTarget.classList.remove("border-gray-300");
        this.zipFeedbackTarget.textContent = "Zip code cannot be empty.";
        this.zipFeedbackTarget.classList.add("text-red-500", "text-sm", "mt-1");
        isFormValid = false;
      } else if (!/^\d{5}(-\d{4})?$/.test(zip)) {
        this.zipInputTarget.classList.add("border-red-500");
        this.zipInputTarget.classList.remove("border-gray-300");
        this.zipFeedbackTarget.textContent = "Zip must be in the format 12345 or 12345-6789.";
        this.zipFeedbackTarget.classList.add("text-red-500", "text-sm", "mt-1");
        isFormValid = false;
      } else {
        this.zipInputTarget.classList.remove("border-red-500");
        this.zipInputTarget.classList.add("border-gray-300");
        this.zipFeedbackTarget.textContent = "";
        this.zipFeedbackTarget.classList.remove("text-red-500");
      }
    } else {
      this.zipFeedbackTarget.hidden = true;
      this.zipInputTarget.classList.remove("border-red-500");
      this.zipInputTarget.classList.add("border-gray-300");
    }

    this.submitButtonTarget.disabled = !isFormValid
  }

  validatePresence(inputTarget, feedbackTarget, errorMessage) {
    if (inputTarget.value.trim() === "") {
      inputTarget.classList.add("border-red-500")
      inputTarget.classList.remove("border-gray-300")
      feedbackTarget.textContent = errorMessage
      feedbackTarget.classList.add("text-red-500", "text-sm", "mt-1")
      feedbackTarget.hidden = false
      return false
    } else {
      inputTarget.classList.remove("border-red-500")
      inputTarget.classList.add("border-gray-300")
      feedbackTarget.textContent = ""
      feedbackTarget.classList.remove("text-red-500")
      feedbackTarget.hidden = true
      return true
    }
  }
}