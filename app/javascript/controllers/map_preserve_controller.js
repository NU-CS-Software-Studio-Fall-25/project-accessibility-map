import { Controller } from "@hotwired/stimulus"

// Preserves map coordinates when forms are submitted via Turbo
// Updates hidden fields with current map center before form submission
// Also updates pagination links with current map coordinates
export default class extends Controller {
  connect() {
    // Listen for form submissions and update coordinates from map
    this.element.addEventListener('submit', (event) => {
      this.updateCoordinatesBeforeSubmit(event)
    })

    // Listen for pagination link clicks and update coordinates
    this.element.addEventListener('click', (event) => {
      const link = event.target.closest('a')
      if (link && link.closest('.flickr_pagination')) {
        this.updatePaginationLink(link, event)
      }
    })
  }

  updateCoordinatesBeforeSubmit(event) {
    const mapInstance = this.getMapInstance()
    if (!mapInstance) return

    const center = mapInstance.getCenter()
    if (center) {
      const lat = center.lat.toFixed(8)
      const lng = center.lng.toFixed(8)

      // Update hidden fields in the form
      const form = event.target
      const latField = form.querySelector('input[name="latitude"]')
      const lngField = form.querySelector('input[name="longitude"]')

      if (latField) latField.value = lat
      if (lngField) lngField.value = lng
    }
  }

  updatePaginationLink(link, event) {
    const mapInstance = this.getMapInstance()
    if (!mapInstance) return

    const center = mapInstance.getCenter()
    if (center) {
      const lat = center.lat.toFixed(8)
      const lng = center.lng.toFixed(8)

      // Update the link URL with current map coordinates
      const url = new URL(link.href)
      url.searchParams.set('latitude', lat)
      url.searchParams.set('longitude', lng)
      link.href = url.toString()
    }
  }

  getMapInstance() {
    const mapId = 'locations-map'

    // Method 1: Check window.mapkick.maps
    if (window.mapkick && window.mapkick.maps && window.mapkick.maps[mapId]) {
      return window.mapkick.maps[mapId]
    }

    if (window.mapkick && window.mapkick.maps) {
      const mapIds = Object.keys(window.mapkick.maps)
      if (mapIds.length > 0) {
        return window.mapkick.maps[mapIds[0]]
      }
    }

    // Method 2: Find via canvas element
    const canvas = document.querySelector('#locations-map canvas')
    if (canvas) {
      const mapContainer = canvas.closest('[data-mapkick]') || canvas.parentElement
      if (mapContainer && mapContainer._map) {
        return mapContainer._map
      }
      if (canvas._map) {
        return canvas._map
      }
      if (canvas.parentElement && canvas.parentElement._mapboxglMap) {
        return canvas.parentElement._mapboxglMap
      }
    }

    // Method 3: Check if mapkick stores it differently
    const mapElement = document.getElementById(mapId)
    if (mapElement && mapElement._map) {
      return mapElement._map
    }

    return null
  }
}

