import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modal']

  toggle() {
    this.modalTarget.classList.toggle('is-shown')
  }

  close() {
    this.modalTarget.classList.remove('is-shown')
  }

  closeOnEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
}
