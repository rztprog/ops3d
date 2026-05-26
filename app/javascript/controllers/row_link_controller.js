import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="row-link"
export default class extends Controller {
  static values = { url: String }

  go(event) {
    if (event.target.closest("a, button, input, select, textarea")) return

    window.location.href = this.urlValue
  }
}
