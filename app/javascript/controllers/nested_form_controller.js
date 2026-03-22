import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    this.containerTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.preventDefault()
    const row = event.currentTarget.closest(".recipe-form-ingredient-row")
    if (!row) return

    const idInput = row.querySelector('input[name*="[id]"]')
    const destroyInput = row.querySelector('input[name*="[_destroy]"]')

    if (idInput?.value) {
      if (destroyInput) destroyInput.value = "1"
      row.hidden = true
    } else {
      row.remove()
    }
  }
}
