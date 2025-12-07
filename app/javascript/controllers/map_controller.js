import { Controller } from "@hotwired/stimulus"

// Listens for geolocation events and centers map on user location
export default class extends Controller {
  connect() {
    // Listen for the geolocation event dispatched by the geolocate controller
    this.geolocatedHandler = (e) => this.#onUserGeolocated(e)
    document.addEventListener("user:geolocated", this.geolocatedHandler)
  }

  #onUserGeolocated(event) {
    const { lat, lng } = event.detail
    console.log("Map controller: Geolocation received", { lat, lng })
    
    // Try to center map immediately, or retry if map isn't ready yet
    const maxRetries = 10
    const retryDelay = 500
    let retries = 0
    
    const tryCenter = () => {
      if (this.#centerMapOnUserLocation(lat, lng)) {
        this.#addUserMarker(lat, lng)
        console.log("Map centered and marker added")
      } else if (retries < maxRetries) {
        retries++
        console.log(`Map not ready yet, retrying... (${retries}/${maxRetries})`)
        setTimeout(tryCenter, retryDelay)
      } else {
        console.warn("Could not center map on user location after multiple attempts")
      }
    }
    
    tryCenter()
  }

  #centerMapOnUserLocation(lat, lng) {
    // Try to find the Leaflet map instance
    // mapkick creates a global window.mapkickMaps object
    if (!window.mapkickMaps) {
      console.debug("window.mapkickMaps not initialized yet")
      return false
    }
    
    const mapIds = Object.keys(window.mapkickMaps)
    if (mapIds.length === 0) {
      console.debug("No maps found in window.mapkickMaps")
      return false
    }
    
    const mapId = mapIds[0]
    const map = window.mapkickMaps[mapId]
    
    if (!map) {
      console.debug(`Map with id ${mapId} is null`)
      return false
    }
    
    if (!map.setView) {
      console.debug("Map does not have setView method")
      return false
    }
    
    try {
      map.setView([lat, lng], 15)
      console.log("Map centered to user location")
      return true
    } catch (error) {
      console.error("Error centering map:", error)
      return false
    }
  }

  #addUserMarker(lat, lng) {
    if (!window.mapkickMaps) return
    
    const mapIds = Object.keys(window.mapkickMaps)
    if (mapIds.length === 0) return
    
    const mapId = mapIds[0]
    const map = window.mapkickMaps[mapId]
    
    if (!map || !window.L) return
    
    try {
      // Add a blue marker for the user's current location
      const userMarker = window.L.circleMarker([lat, lng], {
        radius: 8,
        fillColor: "#3b82f6",
        color: "#1e40af",
        weight: 3,
        opacity: 1,
        fillOpacity: 0.7
      })
        .bindPopup("📍 Your Location")
        .addTo(map)
      
      // Store reference to remove it later if needed
      if (!window.userLocationMarker) {
        window.userLocationMarker = userMarker
      }
      console.log("User location marker added")
    } catch (error) {
      console.error("Error adding user marker:", error)
    }
  }

  disconnect() {
    if (this.geolocatedHandler) {
      document.removeEventListener("user:geolocated", this.geolocatedHandler)
    }
  }
}
