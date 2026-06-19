import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]

  wrap(before, after = before) {
    const textarea = this.textareaTarget

    const start = textarea.selectionStart
    const end = textarea.selectionEnd

    const selected = textarea.value.substring(start, end)

    textarea.setRangeText(
      `${before}${selected}${after}`,
      start,
      end,
      "end"
    )

    textarea.focus()
  }

  bold() {
    this.wrap("**")
  }

  italic() {
    this.wrap("*")
  }

  h2() {
    this.wrap("\n## ", "")
  }

  list() {
    this.wrap("\n- ", "")
  }
}