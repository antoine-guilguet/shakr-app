import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._onDocumentClick = this.onDocumentClick.bind(this)
    this._onDocumentKeydown = this.onDocumentKeydown.bind(this)

    document.addEventListener("click", this._onDocumentClick, true)
    document.addEventListener("keydown", this._onDocumentKeydown, true)
  }

  disconnect() {
    document.removeEventListener("click", this._onDocumentClick, true)
    document.removeEventListener("keydown", this._onDocumentKeydown, true)
  }

  onDocumentClick(event) {
    if (!this.element.open) return
    if (this.element.contains(event.target)) return
    this.element.removeAttribute("open")
  }

  onDocumentKeydown(event) {
    if (!this.element.open) return
    if (event.key !== "Escape") return

    this.element.removeAttribute("open")
    const summary = this.element.querySelector("summary")
    if (summary) summary.focus()
  }
}

