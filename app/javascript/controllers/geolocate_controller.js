import { Controller } from "@hotwired/stimulus"

connect() {
  console.log("[geolocate] connect")
  // ensure we actually call getCurrentPosition()
  navigator.geolocation.getCurrentPosition(
    (pos)=>{ /* ... */ },
    (err)=>{ console.warn("geo error", err) },
    { enableHighAccuracy: true, timeout: 10000, maximumAge: 300000 }
  )
}

// Prompts for geolocation (only once), saves coords to localStorage,
// and dispatches "user:geolocated" with { lat, lng, accuracy }.
export default class extends Controller {
  connect() {
    console.log("Geolocate controller connecting...")
    
    if (!("geolocation" in navigator)) {
      console.warn("Geolocation not supported by this browser")
      return
    }
    
    if (!(window.isSecureContext || ["localhost","127.0.0.1"].includes(location.hostname))) {
      console.warn("Geolocation requires HTTPS or localhost. Current context:", location.hostname)
      return
    }

    // If we already have a saved location, emit it immediately
    const saved = this.#readSaved();
    if (saved && saved.lat && saved.lng) {
      console.log("Found saved location in localStorage:", saved)
      this.#dispatch(saved)
      return
    }

    // If permission is granted, fetch now; if prompt, ask; if denied, do nothing
    const tryRequest = () => this.request();
    
    if (navigator.permissions?.query) {
      navigator.permissions.query({ name: "geolocation" })
        .then(s => {
          console.log("Geolocation permission state:", s.state)
          if (s.state === "granted") {
            console.log("Permission already granted, requesting location...")
            tryRequest()
          } else if (s.state === "prompt") {
            console.log("Permission prompt needed, requesting location...")
            tryRequest()
          } else if (s.state === "denied") {
            console.log("Geolocation permission denied by user")
          }
        })
        .catch(err => {
          console.log("Permissions API not fully supported, trying request anyway:", err)
          tryRequest()
        })
    } else {
      console.log("Permissions API not available, requesting location directly...")
      tryRequest()
    }
  }

  // Optional: call from a button: data-action="click->geolocate#request"
  request() {
    console.log("Requesting geolocation from browser...")
    this.#showLoadingIndicator();
    
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const { latitude: lat, longitude: lng, accuracy } = pos.coords;
        const payload = { lat, lng, accuracy, at: Date.now() };
        console.log("Geolocation received:", payload)
        localStorage.setItem("userLocation", JSON.stringify(payload));
        this.#hideLoadingIndicator();
        this.#dispatch(payload);
      },
      (err) => {
        console.error("Geolocation error:", err?.code, err?.message);
        this.#hideLoadingIndicator();
        
        switch(err?.code) {
          case 1:
            console.log("User denied geolocation permission");
            break;
          case 2:
            console.warn("Position unavailable");
            break;
          case 3:
            console.warn("Geolocation request timeout");
            break;
          default:
            console.warn("Unknown geolocation error");
        }
      },
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 300000 }
    );
  }

  #showLoadingIndicator() {
    console.debug("Requesting your location...");
  }

  #hideLoadingIndicator() {
    console.debug("Location request completed");
  }

  #dispatch(detail) {
    console.log("Dispatching user:geolocated event with:", detail)
    this.element.dispatchEvent(new CustomEvent("user:geolocated", { bubbles: true, detail }));
  }
  
  #readSaved() {
    try {
      const data = localStorage.getItem("userLocation")
      if (!data) return null
      return JSON.parse(data)
    } catch (e) {
      console.error("Error reading saved location:", e)
      return null
    }
  }
}
