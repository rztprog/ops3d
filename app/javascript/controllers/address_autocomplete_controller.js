import { Controller } from "@hotwired/stimulus"

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
      const url = `https://data.geopf.fr/geocodage/completion/?text=${encodeURIComponent(query)}&maximumResponses=5`

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
      const props = result.properties || result

      const label =
        props.fulltext ||
        props.label ||
        props.name ||
        props.text ||
        ""

      if (!label) return

      const item = document.createElement("button")
      item.type = "button"
      item.className = "block w-full px-4 py-3 text-left text-sm hover:bg-gray-50"
      item.textContent = label

      item.addEventListener("click", () => {
        this.selectAddress(label)
      })

      this.suggestionsTarget.appendChild(item)
    })
  }

  async selectAddress(label) {
    this.inputTarget.value = label
    this.clearSuggestions()

    try {
      const url = `https://data.geopf.fr/geocodage/search?q=${encodeURIComponent(label)}&limit=1`

      const response = await fetch(url)
      if (!response.ok) return

      const data = await response.json()
      const feature = data.features?.[0]
      const props = feature?.properties

      if (!props) return

      const houseNumber = props.housenumber || ""
      const streetName = props.street || props.name || ""
      const addressLine = [houseNumber, streetName].filter(Boolean).join(" ")

      this.inputTarget.value = addressLine || props.label || label

      if (this.hasPostalCodeTarget) {
        this.postalCodeTarget.value = props.postcode || ""
      }

      if (this.hasCityTarget) {
        this.cityTarget.value = props.city || ""
      }

      if (this.hasCountryTarget) {
        this.countryTarget.value = "France"
      }
    } catch (error) {
      console.error("Address selection error:", error)
    }
  }

  clearSuggestions() {
    this.suggestionsTarget.innerHTML = ""
  }
}