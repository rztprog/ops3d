import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 3000 }
  }

  connect() {
    // fade-in
    requestAnimationFrame(() => {
      this.element.classList.remove("opacity-0", "-translate-y-2")
      this.element.classList.add("opacity-100", "translate-y-0")
    })

    // auto-hide
    this.timeout = setTimeout(() => {
      this.fadeOut()
    }, this.delayValue)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
    if (this.removeTimeout) clearTimeout(this.removeTimeout)
  }

  fadeOut() {
    this.element.classList.remove("opacity-100", "translate-y-0")
    this.element.classList.add("opacity-0", "-translate-y-2")

    this.removeTimeout = setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
