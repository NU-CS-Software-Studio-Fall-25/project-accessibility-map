import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    fallbackLat: { type: Number, default: 42.057853 },
    fallbackLng: { type: Number, default: -87.676143 },
    locationsUrl: String,
    initialLat: Number,
    initialLng: Number
  }

  connect() {
    // Prompt for user's location on page load
    // If denied or unavailable, use Evanston, IL default coordinates
    this.requestLocation()
  }

  async requestLocation() {
    if (!navigator.geolocation) {
      // Geolocation not supported - use default Evanston, IL coordinates
      this.useFallbackLocation()
      return
    }

    try {
      const position = await this.getCurrentPosition()
      const { latitude, longitude } = position.coords
      // User granted permission - use their location
      this.updateMapWithLocation(latitude, longitude)
    } catch (error) {
      // Location permission denied or error - use default Evanston, IL coordinates
      this.useFallbackLocation()
    }
  }

  getCurrentPosition() {
    return new Promise((resolve, reject) => {
      navigator.geolocation.getCurrentPosition(
        resolve,
        reject,
        {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 0
        }
      )
    })
  }

  useFallbackLocation() {
    // Default to Evanston, IL coordinates
    // These coordinates are only used for querying DB and sorting locations
    this.updateMapWithLocation(this.fallbackLatValue, this.fallbackLngValue)
  }

  updateMapWithLocation(lat, lng) {
    // Store coordinates
    this.latitude = lat
    this.longitude = lng

    // Check if location params are already in URL
    const urlParams = new URLSearchParams(window.location.search)
    const urlLat = urlParams.get('latitude')
    const urlLng = urlParams.get('longitude')

    // If coordinates are different, reload page with new coordinates
    // This will trigger a fresh query with distance-based sorting
    if (!urlLat || !urlLng ||
        Math.abs(parseFloat(urlLat) - lat) > 0.0001 ||
        Math.abs(parseFloat(urlLng) - lng) > 0.0001) {
      this.reloadWithLocationParams(lat, lng)
    }
  }

  // Calculate distance between two coordinates using Haversine formula (in kilometers)
  calculateDistance(lat1, lng1, lat2, lng2) {
    const R = 6371 // Earth's radius in kilometers
    const dLat = this.toRad(lat2 - lat1)
    const dLng = this.toRad(lng2 - lng1)
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
              Math.sin(dLng / 2) * Math.sin(dLng / 2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return R * c
  }

  toRad(degrees) {
    return degrees * (Math.PI / 180)
  }

  waitForMap(callback, maxAttempts = 50) {
    let attempts = 0
    const checkMap = () => {
      const mapInstance = this.getMapInstance()
      if (mapInstance) {
        callback()
      } else if (attempts < maxAttempts) {
        attempts++
        setTimeout(checkMap, 100)
      } else {
        // If we can't find the map instance after waiting, it's okay
        // The map will still work, we just can't programmatically center it
        console.debug("Map instance not found, but map should still be functional")
      }
    }
    checkMap()
  }

  getMapInstance() {
    // Try multiple ways to find the map instance

    // Method 1: Check window.mapkick.maps (if mapkick exposes it this way)
    const mapId = this.getMapId()
    if (mapId && window.mapkick && window.mapkick.maps && window.mapkick.maps[mapId]) {
      return window.mapkick.maps[mapId]
    }

    // Method 2: Try to find map instance by searching all maps
    if (window.mapkick && window.mapkick.maps) {
      const mapIds = Object.keys(window.mapkick.maps)
      if (mapIds.length > 0) {
        return window.mapkick.maps[mapIds[0]]
      }
    }

    // Method 3: Find the canvas element (Mapbox GL JS creates a canvas)
    const canvas = this.element.querySelector('canvas')
    if (canvas) {
      // Mapbox stores the map instance on the canvas element or its parent
      const mapContainer = canvas.closest('[data-mapkick]') || canvas.parentElement
      if (mapContainer && mapContainer._map) {
        return mapContainer._map
      }
      // Sometimes Mapbox stores it directly on the canvas
      if (canvas._map) {
        return canvas._map
      }
    }

    // Method 4: Check if Mapbox stores maps globally
    if (window.mapboxgl && window.mapboxgl.Map) {
      // Mapbox might store instances in a registry
      // Try to find by checking all elements
      const allElements = document.querySelectorAll('[id]')
      for (const el of allElements) {
        if (el._mapboxglMap) {
          return el._mapboxglMap
        }
      }
    }

    return null
  }

  getMapId() {
    // Find the map container - mapkick creates a div with an ID
    const mapContainer = this.element.querySelector('[id^="mapkick"]') ||
                         this.element.querySelector('#locations-map') ||
                         this.element.querySelector('[id]')

    return mapContainer?.getAttribute('id')
  }

  updateMapData(lat, lng) {
    // Since we're not filtering by radius, we don't need to update the map data
    // The map already shows all locations. We just need to center it.
    // This method is kept for potential future use but currently does nothing
    // as the map data doesn't change when location changes
  }

  reloadWithLocationParams(lat, lng) {
    const newUrl = new URL(window.location.href)
    newUrl.searchParams.set('latitude', lat)
    newUrl.searchParams.set('longitude', lng)
    // Remove page param to start from page 1
    newUrl.searchParams.delete('page')

    // Full page reload to refresh the entire page with new coordinates
    // This ensures the DB query uses the new coordinates for sorting
    window.location.href = newUrl.toString()
  }

  centerMap(lat, lng) {
    const mapInstance = this.getMapInstance()
    if (!mapInstance) return

    // Use Mapbox GL JS methods to center the map
    if (mapInstance.flyTo) {
      mapInstance.flyTo({
        center: [lng, lat],
        zoom: 13,
        duration: 1000
      })
    } else if (mapInstance.setCenter) {
      mapInstance.setCenter([lng, lat])
      if (mapInstance.setZoom) {
        mapInstance.setZoom(13)
      }
    }
  }

  get latitude() {
    return this._latitude
  }

  set latitude(value) {
    this._latitude = value
    this.element.setAttribute('data-latitude', value)
  }

  get longitude() {
    return this._longitude
  }

  set longitude(value) {
    this._longitude = value
    this.element.setAttribute('data-longitude', value)
  }
}

