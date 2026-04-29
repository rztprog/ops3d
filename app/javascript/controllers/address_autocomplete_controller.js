import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static targets = ["input", "suggestions", "city", "postalCode", "country"]

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)

    const query = this.inputTarget.value.trim()

    if (query.length < 3) {
      this.clearSuggestions()
      return
    }

    this.timeout = setTimeout(() => {
      this.fetchSuggestions(query)
    }, 300)
  }

  async fetchSuggestions(query) {
    try {
      const url = `https://data.geopf.fr/geocodage/completion?text=${encodeURIComponent(query)}&limit=5`

      const response = await fetch(url)
      if (!response.ok) return

      const data = await response.json()
      this.renderSuggestions(data)
    } catch (error) {
      console.error("Address autocomplete error:", error)
    }
  }

  renderSuggestions(data) {
    this.clearSuggestions()

    const results = data.results || data.features || []

    if (results.length === 0) return

    results.forEach((result) => {
      const item = document.createElement("button")
      item.type = "button"
      item.className = "block w-full px-4 py-3 text-left text-sm hover:bg-gray-50"

      const label = result.fulltext || result.label || result.properties?.label || result.properties?.name
      const city = result.city || result.properties?.city || result.properties?.city_name
      const postcode = result.postcode || result.properties?.postcode || result.properties?.postal_code

      item.textContent = label

      item.addEventListener("click", () => {
        this.inputTarget.value = label || this.inputTarget.value

        if (city && this.hasCityTarget) this.cityTarget.value = city
        if (postcode && this.hasPostalCodeTarget) this.postalCodeTarget.value = postcode
        if (this.hasCountryTarget) this.countryTarget.value = "France"

        this.clearSuggestions()
      })

      this.suggestionsTarget.appendChild(item)
    })
  }

  clearSuggestions() {
    this.suggestionsTarget.innerHTML = ""
  }
}