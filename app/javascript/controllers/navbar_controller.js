import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  
  static targets = ["menu", "openIcon", "closeIcon"]

  connect() {
      console.log("navbar connected")

    this.isOpen = false
  }

  toggle() {
      console.log("toggle")

    this.isOpen = !this.isOpen

    this.menuTarget.classList.toggle("hidden", !this.isOpen)
    this.openIconTarget.classList.toggle("hidden", this.isOpen)
    this.closeIconTarget.classList.toggle("hidden", !this.isOpen)
  }
}