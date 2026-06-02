// app/javascript/controllers/mobile_bottom_nav_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.lastScrollY = window.scrollY
    this.ticking = false

    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  onScroll() {
    if (this.ticking) return

    window.requestAnimationFrame(() => {
      const currentScrollY = window.scrollY
      const diff = currentScrollY - this.lastScrollY

      if (currentScrollY < 80) {
        this.show()
      } else if (diff > 8) {
        this.hide()
      } else if (diff < -8) {
        this.show()
      }

      this.lastScrollY = currentScrollY
      this.ticking = false
    })

    this.ticking = true
  }

  hide() {
    this.element.classList.add("translate-y-full")
  }

  show() {
    this.element.classList.remove("translate-y-full")
  }
}