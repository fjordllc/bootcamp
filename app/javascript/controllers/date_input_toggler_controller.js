import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['checkbox', 'dateInputArea', 'dateInput']

  connect() {
    this.checkboxTarget.checked = this.dateInputTarget.value !== ''
    this.syncDateInput()
  }

  syncDateInput() {
    if (this.checkboxTarget.checked) {
      this.dateInputAreaTarget.style.display = 'flex'
    } else {
      this.dateInputAreaTarget.style.display = 'none'
      this.dateInputTarget.value = ''
    }
  }
}
