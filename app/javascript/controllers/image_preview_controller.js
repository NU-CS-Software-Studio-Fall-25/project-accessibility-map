import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["previewContainer", "fileInput"]

  connect() {
    // Create a DataTransfer object to accumulate files
    this.dataTransfer = new DataTransfer()
  }

  displayPreviews(event) {
    const files = event.target.files

    Array.from(files).forEach(file => {
      if (!file.type.match('image.*')) {
        return
      }

      // Add file to DataTransfer object
      this.dataTransfer.items.add(file)

      const reader = new FileReader()

      reader.onload = (e) => {
        const previewDiv = document.createElement('div')
        previewDiv.className = 'relative group flex-shrink-0'
        previewDiv.dataset.fileName = file.name // Store filename for removal

        const img = document.createElement('img')
        img.src = e.target.result
        img.className = 'h-64 object-cover rounded-lg'

        const badge = document.createElement('span')
        badge.textContent = 'New'
        badge.className = 'absolute top-2 left-2 bg-green-500 text-white text-xs font-bold py-1 px-2 rounded'

        const removeButton = document.createElement('button')
        removeButton.textContent = 'Delete'
        removeButton.type = 'button'
        removeButton.className = 'text-sm absolute top-2 right-2 bg-red-500 hover:bg-red-700 text-white text-xs font-bold py-1 px-2 rounded opacity-0 group-hover:opacity-100 transition-opacity'
        removeButton.addEventListener('click', () => {
          this.removePreview(previewDiv, file.name)
        })

        previewDiv.appendChild(img)
        previewDiv.appendChild(badge)
        previewDiv.appendChild(removeButton)

        this.previewContainerTarget.appendChild(previewDiv)
      }

      reader.readAsDataURL(file)
    })

    // Update the file input with accumulated files
    this.fileInputTarget.files = this.dataTransfer.files
  }

  removePreview(previewDiv, fileName) {
    // Remove from DataTransfer
    const newDataTransfer = new DataTransfer()
    Array.from(this.dataTransfer.files).forEach(file => {
      if (file.name !== fileName) {
        newDataTransfer.items.add(file)
      }
    })
    this.dataTransfer = newDataTransfer

    // Update input files
    this.fileInputTarget.files = this.dataTransfer.files

    // Remove preview element
    previewDiv.remove()
  }
}
