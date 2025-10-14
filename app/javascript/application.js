// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import 'flowbite'
import "leaflet"

document.addEventListener("turbo:load", () => {
  const el = document.getElementById("ofm-map");
  if (!el) return;

  const lat = parseFloat(el.dataset.lat);
  const lng = parseFloat(el.dataset.lng);
  if (isNaN(lat) || isNaN(lng)) return;

  const map = L.map(el).setView([lat, lng], 16);

  L.tileLayer("https://tile.openfreemap.org/{z}/{x}/{y}.png", {
    maxZoom: 20,
    attribution: "&copy; OpenStreetMap contributors, OpenFreeMap",
  }).addTo(map);

  L.marker([lat, lng]).addTo(map);
});