import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    locationsUrl: String
  }

  connect() {
    // Wait for map to initialize, then wait for data to load, then center/zoom to fit all locations
    this.waitForMap(() => {
      const mapInstance = this.getMapInstance()
      if (!mapInstance) return

      // Try to listen for when the map data loads
      if (mapInstance.on) {
        // Mapbox GL JS uses 'load' event
        mapInstance.on('load', () => {
          // Wait a bit for markers to be added
          setTimeout(() => {
            this.centerMapToLocations()
          }, 500)
        })

        // If map is already loaded, center immediately
        if (mapInstance.loaded()) {
          setTimeout(() => {
            this.centerMapToLocations()
          }, 500)
        }
      } else {
        // Fallback: wait a bit then center
        setTimeout(() => {
          this.centerMapToLocations()
        }, 1500)
      }
    }, 50)
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
      }
    }
    checkMap()
  }

  getMapInstance() {
    // Try multiple ways to find the map instance
    const mapId = this.getMapId()
    if (mapId && window.mapkick && window.mapkick.maps && window.mapkick.maps[mapId]) {
      return window.mapkick.maps[mapId]
    }

    if (window.mapkick && window.mapkick.maps) {
      const mapIds = Object.keys(window.mapkick.maps)
      if (mapIds.length > 0) {
        return window.mapkick.maps[mapIds[0]]
      }
    }

    const canvas = this.element.querySelector('canvas')
    if (canvas) {
      const mapContainer = canvas.closest('[data-mapkick]') || canvas.parentElement
      if (mapContainer && mapContainer._map) {
        return mapContainer._map
      }
      if (canvas._map) {
        return canvas._map
      }
    }

    if (window.mapboxgl && window.mapboxgl.Map) {
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
    const mapContainer = this.element.querySelector('[id^="mapkick"]') ||
                         this.element.querySelector('#locations-map') ||
                         this.element.querySelector('[id]')

    return mapContainer?.getAttribute('id')
  }

  async centerMapToLocations() {
    if (!this.hasLocationsUrlValue) {
      console.debug("No locations URL provided to map controller")
      return
    }

    try {
      const response = await fetch(this.locationsUrlValue)
      if (!response.ok) {
        console.debug("Failed to fetch locations:", response.status)
        return
      }

      const locations = await response.json()

      if (!locations || locations.length === 0) {
        console.debug("No locations found to center map on")
        return
      }

      console.debug(`Centering map on ${locations.length} locations`)

      // Calculate bounds that contain all locations
      const bounds = this.calculateBounds(locations)

      if (bounds) {
        console.debug("Calculated bounds:", bounds)
        this.fitMapToBounds(bounds)
      } else {
        console.debug("Could not calculate bounds from locations")
      }
    } catch (error) {
      console.debug("Could not fetch locations for map centering:", error)
    }
  }

  calculateBounds(locations) {
    if (!locations || locations.length === 0) return null

    let minLat = locations[0].latitude
    let maxLat = locations[0].latitude
    let minLng = locations[0].longitude
    let maxLng = locations[0].longitude

    locations.forEach(location => {
      if (location.latitude && location.longitude) {
        minLat = Math.min(minLat, location.latitude)
        maxLat = Math.max(maxLat, location.latitude)
        minLng = Math.min(minLng, location.longitude)
        maxLng = Math.max(maxLng, location.longitude)
      }
    })

    return {
      north: maxLat,
      south: minLat,
      east: maxLng,
      west: minLng
    }
  }

  fitMapToBounds(bounds) {
    const mapInstance = this.getMapInstance()
    if (!mapInstance) {
      console.debug("Map instance not found for centering")
      return
    }

    // If there's only one location, center on it with a reasonable zoom
    if (bounds.north === bounds.south && bounds.east === bounds.west) {
      if (mapInstance.flyTo) {
        mapInstance.flyTo({
          center: [bounds.east, bounds.north],
          zoom: 14,
          duration: 1000
        })
      } else if (mapInstance.setCenter && mapInstance.setZoom) {
        mapInstance.setCenter([bounds.east, bounds.north])
        mapInstance.setZoom(14)
      }
      return
    }

    // Use Mapbox GL JS fitBounds method
    if (mapInstance.fitBounds) {
      mapInstance.fitBounds(
        [[bounds.west, bounds.south], [bounds.east, bounds.north]],
        {
          padding: { top: 50, bottom: 50, left: 50, right: 50 }, // Add padding around the bounds
          maxZoom: 15, // Limit max zoom level
          duration: 1000 // Animation duration
        }
      )
    } else if (mapInstance.flyTo) {
      // Use flyTo as alternative
      const centerLat = (bounds.north + bounds.south) / 2
      const centerLng = (bounds.east + bounds.west) / 2

      // Calculate zoom based on bounds
      const latDiff = bounds.north - bounds.south
      const lngDiff = bounds.east - bounds.west
      const maxDiff = Math.max(latDiff, lngDiff)

      let zoom = 13
      if (maxDiff > 0.1) zoom = 10
      else if (maxDiff > 0.05) zoom = 11
      else if (maxDiff > 0.02) zoom = 12
      else if (maxDiff > 0.01) zoom = 13
      else if (maxDiff > 0.005) zoom = 14
      else zoom = 15

      mapInstance.flyTo({
        center: [centerLng, centerLat],
        zoom: zoom,
        duration: 1000
      })
    } else if (mapInstance.setCenter && mapInstance.setZoom) {
      // Fallback: center on the middle of bounds and calculate zoom
      const centerLat = (bounds.north + bounds.south) / 2
      const centerLng = (bounds.east + bounds.west) / 2
      mapInstance.setCenter([centerLng, centerLat])

      // Calculate appropriate zoom level based on bounds
      const latDiff = bounds.north - bounds.south
      const lngDiff = bounds.east - bounds.west
      const maxDiff = Math.max(latDiff, lngDiff)

      // Rough zoom calculation
      let zoom = 13
      if (maxDiff > 0.1) zoom = 10
      else if (maxDiff > 0.05) zoom = 11
      else if (maxDiff > 0.02) zoom = 12
      else if (maxDiff > 0.01) zoom = 13
      else if (maxDiff > 0.005) zoom = 14
      else zoom = 15

      mapInstance.setZoom(zoom)
    }
  }
}

