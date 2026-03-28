import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "indicator", "prevButton", "nextButton"]

  connect() {
    this.index = 0
    this.updateUi()
  }

  next(event) {
    event.preventDefault()
    this.goTo(Math.min(1, this.index + 1))
  }

  prev(event) {
    event.preventDefault()
    this.goTo(Math.max(0, this.index - 1))
  }

  goTo(i) {
    this.index = i
    this.updateUi()
  }

  updateUi() {
    if (!this.hasTrackTarget) return

    const pct = this.index === 0 ? "0%" : "-50%"
    this.trackTarget.style.transform = `translateX(${pct})`

    if (this.hasIndicatorTarget) {
      this.indicatorTarget.textContent = `${this.index + 1} / 2`
    }

    if (this.hasPrevButtonTarget) {
      this.prevButtonTarget.disabled = this.index === 0
    }

    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.disabled = this.index === 1
    }
  }
}
