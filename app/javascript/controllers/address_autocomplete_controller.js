import { Controller } from "@hotwired/stimulus"
import { SearchBoxCore, SessionToken } from '@mapbox/search-js-core'

export default class extends Controller {
  static targets = [
    "searchInput",
    "addressField",
    "cityField",
    "stateField",
    "zipField",
    "countryField",
    "latitudeField",
    "longitudeField",
    "confirmationDisplay",
    "submitButton"
  ]

  static values = {
    accessToken: String,
    currentAddress: String // For edit mode, pass current address as initial value
  }

  connect() {
    this.initializeSearchBox()
    this.validateFields()
  }

  async initializeSearchBox() {
    // Initialize Mapbox Search Box Core
    this.searchBox = new SearchBoxCore({
      accessToken: this.accessTokenValue,
      types: "address",
      options: {
        language: 'en',
        country: 'US', // Can be modified to support multiple countries
      }
    })

    // Create a session token for tracking search sessions
    this.sessionToken = new SessionToken()

    // Set up event listeners
    this.searchInputTarget.addEventListener('input', this.handleInput.bind(this))
    this.searchInputTarget.addEventListener('blur', this.handleBlur.bind(this))

    // If editing, pre-populate with current address
    if (this.hasCurrentAddressValue && this.currentAddressValue) {
      this.searchInputTarget.value = this.currentAddressValue
    }
  }

  async handleInput(event) {
    const query = event.target.value

    // Clear hidden fields when user starts typing
    this.clearAddressFields()
    this.validateFields()

    if (query.length < 3) {
      this.hideSuggestions()
      return
    }

    // Fetch suggestions from Mapbox
    try {
      const response = await this.searchBox.suggest(query, { sessionToken: this.sessionToken })
      this.displaySuggestions(response.suggestions)
    } catch (error) {
      console.error('Error fetching suggestions:', error)
    }
  }

  async selectSuggestion(suggestion) {
    try {
      // Retrieve full details for the selected suggestion
      const result = await this.searchBox.retrieve(suggestion, { sessionToken: this.sessionToken })

      if (result && result.features && result.features.length > 0) {
        const feature = result.features[0]
        this.populateAddressFields(feature)
        this.searchInputTarget.value = feature.properties.full_address || feature.properties.place_formatted
        this.hideSuggestions()
        this.showConfirmation(feature.properties.full_address || feature.properties.place_formatted)
        this.validateFields()
      }
    } catch (error) {
      console.error('Error retrieving address details:', error)
    }
  }

  populateAddressFields(feature) {
    const props = feature.properties
    const context = props.context || {}

    // Extract address components
    this.addressFieldTarget.value = props.address || ''
    this.cityFieldTarget.value = context.place?.name || ''
    this.stateFieldTarget.value = context.region?.region_code || ''
    this.zipFieldTarget.value = context.postcode?.name || ''
    this.countryFieldTarget.value = context.country?.name || 'United States'

    // Extract coordinates
    if (feature.geometry && feature.geometry.coordinates) {
      this.longitudeFieldTarget.value = feature.geometry.coordinates[0]
      this.latitudeFieldTarget.value = feature.geometry.coordinates[1]
    }
  }

  clearAddressFields() {
    this.addressFieldTarget.value = ''
    this.cityFieldTarget.value = ''
    this.stateFieldTarget.value = ''
    this.zipFieldTarget.value = ''
    this.countryFieldTarget.value = ''
    this.latitudeFieldTarget.value = ''
    this.longitudeFieldTarget.value = ''
    this.hideConfirmation()
  }

  handleBlur(event) {
    // Delay to allow click on suggestions
    setTimeout(() => {
      // If no address was selected (hidden fields empty), clear the search input
      if (!this.addressFieldTarget.value) {
        this.searchInputTarget.value = ''
        this.hideSuggestions()
      }
    }, 200)
  }

  displaySuggestions(suggestions) {
    // Store suggestions for keyboard navigation
    this.currentSuggestions = suggestions

    // Create/update suggestions dropdown
    let dropdown = this.element.querySelector('[data-suggestions-dropdown]')

    if (!dropdown) {
      dropdown = document.createElement('div')
      dropdown.setAttribute('data-suggestions-dropdown', '')
      dropdown.setAttribute('id', 'address-suggestions')
      dropdown.setAttribute('role', 'listbox')
      dropdown.setAttribute('aria-label', 'Address suggestions')
      dropdown.className = 'absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-auto'
      this.searchInputTarget.parentElement.appendChild(dropdown)

      // Set up keyboard navigation
      this.searchInputTarget.setAttribute('aria-expanded', 'true')
      this.searchInputTarget.setAttribute('aria-controls', 'address-suggestions')
    }

    dropdown.innerHTML = ''
    this.selectedIndex = -1

    if (suggestions.length === 0) {
      dropdown.innerHTML = '<div class="px-4 py-2 text-sm text-gray-500" role="option">No suggestions found</div>'
      this.searchInputTarget.setAttribute('aria-expanded', 'false')
      return
    }

    suggestions.forEach((suggestion, index) => {
      const item = document.createElement('div')
      item.setAttribute('role', 'option')
      item.setAttribute('id', `suggestion-${index}`)
      item.setAttribute('tabindex', '-1')
      item.setAttribute('data-suggestion-index', index)
      item.className = 'px-4 py-2 text-sm cursor-pointer hover:bg-yellow-50 focus:bg-yellow-50 border-b border-gray-100 last:border-0 focus:outline-none focus:ring-2 focus:ring-yellow-400'
      item.textContent = suggestion.full_address || suggestion.place_formatted
      item.addEventListener('click', () => this.selectSuggestion(suggestion))
      item.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault()
          this.selectSuggestion(suggestion)
        }
      })
      dropdown.appendChild(item)
    })

    // Add keyboard event listener to search input if not already added
    if (!this.keydownHandler) {
      this.keydownHandler = this.handleKeydown.bind(this)
      this.searchInputTarget.addEventListener('keydown', this.keydownHandler)
    }
  }

  handleKeydown(event) {
    const dropdown = this.element.querySelector('[data-suggestions-dropdown]')
    if (!dropdown || !this.currentSuggestions) return

    const items = dropdown.querySelectorAll('[role="option"]')
    if (items.length === 0) return

    switch(event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        items[this.selectedIndex].focus()
        items[this.selectedIndex].setAttribute('aria-selected', 'true')
        // Remove aria-selected from other items
        items.forEach((item, idx) => {
          if (idx !== this.selectedIndex) item.removeAttribute('aria-selected')
        })
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        if (this.selectedIndex >= 0) {
          items[this.selectedIndex].focus()
          items[this.selectedIndex].setAttribute('aria-selected', 'true')
          items.forEach((item, idx) => {
            if (idx !== this.selectedIndex) item.removeAttribute('aria-selected')
          })
        } else {
          this.searchInputTarget.focus()
        }
        break
      case 'Escape':
        this.hideSuggestions()
        this.searchInputTarget.focus()
        break
      case 'Enter':
        if (this.selectedIndex >= 0 && items[this.selectedIndex] && this.currentSuggestions[this.selectedIndex]) {
          event.preventDefault()
          this.selectSuggestion(this.currentSuggestions[this.selectedIndex])
        }
        break
    }
  }

  hideSuggestions() {
    const dropdown = this.element.querySelector('[data-suggestions-dropdown]')
    if (dropdown) {
      dropdown.remove()
    }
    if (this.searchInputTarget) {
      this.searchInputTarget.setAttribute('aria-expanded', 'false')
    }
    this.selectedIndex = -1
    this.currentSuggestions = null
  }

  showConfirmation(address) {
    if (this.hasConfirmationDisplayTarget) {
      this.confirmationDisplayTarget.innerHTML = `
        <div class="flex items-center gap-2 text-sm text-green-700 bg-green-50 px-3 py-2 rounded-md">
          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
          </svg>
          <span><strong>Selected:</strong> ${address}</span>
        </div>
      `
      this.confirmationDisplayTarget.classList.remove('hidden')
    }
  }

  hideConfirmation() {
    if (this.hasConfirmationDisplayTarget) {
      this.confirmationDisplayTarget.classList.add('hidden')
    }
  }

  validateFields() {
    // Check if all required fields are populated
    const hasAddress = this.addressFieldTarget.value.trim() !== ''
    const hasCity = this.cityFieldTarget.value.trim() !== ''
    const hasState = this.stateFieldTarget.value.trim() !== ''
    const hasCountry = this.countryFieldTarget.value.trim() !== ''
    const hasCoordinates = this.latitudeFieldTarget.value && this.longitudeFieldTarget.value

    const isValid = hasAddress && hasCity && hasState && hasCountry && hasCoordinates

    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = !isValid
    }
  }

  disconnect() {
    this.hideSuggestions()
  }
}
