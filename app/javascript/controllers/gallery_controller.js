import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery"
export default class extends Controller {
  static targets = ["main"]

  change(event) {
    
    this.mainTarget.src = event.currentTarget.dataset.image
  }
}