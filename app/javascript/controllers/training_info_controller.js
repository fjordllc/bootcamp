import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['checkbox', 'infoBlock', 'endDate']

  connect() {
    if (!this.#hasAllTargets()) return
    this.#syncVisibility()
  }

  toggle() {
    if (!this.#hasAllTargets()) return
    if (!this.checkboxTarget.checked) {
      this.endDateTarget.value = ''
    }
    this.#syncVisibility()
  }

  #syncVisibility() {
    this.infoBlockTarget.style.display = this.checkboxTarget.checked
      ? 'block'
      : 'none'
  }

  #hasAllTargets() {
    return (
      this.hasCheckboxTarget && this.hasInfoBlockTarget && this.hasEndDateTarget
    )
  }
}
