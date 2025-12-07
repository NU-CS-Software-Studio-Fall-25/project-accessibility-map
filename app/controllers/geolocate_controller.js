// app/javascript/controllers/geolocate_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!("geolocation" in navigator)) return;
    if (!(window.isSecureContext || ["localhost","127.0.0.1"].includes(location.hostname))) return;

    // emit saved coords immediately (if any)
    const saved = this._readSaved();
    if (saved) this._dispatch(saved);

    // request now
    this.request();
  }

  // You can also trigger via a button: data-action="click->geolocate#request"
  request() {
    const opts = { enableHighAccuracy: true, timeout: 10000, maximumAge: 300000 };
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const { latitude: lat, longitude: lng, accuracy } = pos.coords;
        const payload = { lat, lng, accuracy, at: Date.now() };
        try { localStorage.setItem("userLocation", JSON.stringify(payload)); } catch {}
        this._dispatch(payload);
      },
      (err) => console.warn("Geolocation error:", err && err.message),
      opts
    );
  }

  _dispatch(detail) {
    this.element.dispatchEvent(new CustomEvent("user:geolocated", { bubbles: true, detail }));
  }

  _readSaved() {
    try {
      const v = JSON.parse(localStorage.getItem("userLocation") || "null");
      if (v && typeof v.lat === "number" && typeof v.lng === "number") return v;
    } catch {}
    return null;
  }
}
