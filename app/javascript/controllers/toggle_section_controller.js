import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle() {
    console.log(this.contentTarget)
    this.contentTarget.classList.toggle("hidden")
  }
}