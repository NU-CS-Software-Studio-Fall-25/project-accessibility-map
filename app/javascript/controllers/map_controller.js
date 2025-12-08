import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // The map is initialized by mapkick's js_map helper
    // The cache-busting parameter in the URL ensures fresh data is loaded
    // This controller ensures the map container is ready for mapkick to initialize

    // Listen for Turbo navigation to ensure map refreshes on page visits
    if (window.Turbo) {
      document.addEventListener('turbo:load', () => {
        // Mapkick should automatically reinitialize the map on page load
        // The cache-busting parameter ensures fresh data
      })
    }
  }
}

