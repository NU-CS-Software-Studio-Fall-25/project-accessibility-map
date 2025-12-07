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
    // Wait a bit for mapkick to initialize the map
    // Always start with initial coordinates (either from URL params or default fallback)
    // The map should already be centered and filtered from server-side
    if (this.hasInitialLatValue && this.hasInitialLngValue) {
      // Map should already be centered from server-side, just ensure it stays centered
      setTimeout(() => {
        this.updateMapWithLocation(this.initialLatValue, this.initialLngValue)
      }, 500)
    }

    // Try to get user's actual location to update the map if different
    // Only update if user's location is significantly different from current location
    // This prevents unnecessary reloads when using default location
    setTimeout(() => {
      this.requestLocation()
    }, 1000) // Slightly longer delay to let initial map load first
  }

  async requestLocation() {
    if (!navigator.geolocation) {
      // Geolocation not supported - already using default, no need to update
      return
    }

    try {
      const position = await this.getCurrentPosition()
      const { latitude, longitude } = position.coords

      // Only update if user's location is significantly different from current location
      // This prevents unnecessary reloads when already using default or similar location
      const currentLat = this.hasInitialLatValue ? this.initialLatValue : this.fallbackLatValue
      const currentLng = this.hasInitialLngValue ? this.initialLngValue : this.fallbackLngValue

      // Calculate distance in km (rough approximation)
      const latDiff = Math.abs(latitude - currentLat)
      const lngDiff = Math.abs(longitude - currentLng)
      const distance = Math.sqrt(latDiff * latDiff + lngDiff * lngDiff) * 111 // rough km conversion

      // Only update if location is more than 1km away (prevents unnecessary updates)
      if (distance > 1) {
        this.updateMapWithLocation(latitude, longitude)
      }
    } catch (error) {
      // Location permission denied or error - already using default, no need to update
      // Don't call useFallbackLocation() as we're already using it
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

    if (!urlLat || !urlLng) {
      // No location in URL, reload with location params
      this.reloadWithLocationParams(lat, lng)
      return
    }

    // Calculate distance between current URL location and new location
    const currentLat = parseFloat(urlLat)
    const currentLng = parseFloat(urlLng)
    const distance = this.calculateDistance(currentLat, currentLng, lat, lng)

    // Only reload if the location is significantly different (more than 1km)
    // This prevents unnecessary reloads and flashing when location is similar
    const significantDistance = 1.0 // kilometers

    if (distance < significantDistance) {
      // Location is very close, just ensure map is centered without reloading
      this.waitForMap(() => {
        this.centerMap(lat, lng)
      }, 20) // Shorter wait since map should be ready
    } else {
      // Location is significantly different, reload with new params to update map center
      // Note: We're not filtering by radius, just updating the center coordinates
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
    // Note: No radius parameter - we're not filtering by radius, just centering the map

    // Use Turbo for a soft reload if available
    if (window.Turbo) {
      window.Turbo.visit(newUrl.toString(), { action: 'replace' })
    } else {
      window.location.href = newUrl.toString()
    }
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

