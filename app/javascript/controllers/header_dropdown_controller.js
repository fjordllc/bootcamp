import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    document.addEventListener('click', this.closeOnClickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.closeOnClickOutside)
  }

  toggle() {
    this.element.classList.toggle('is-opened-dropdown')
  }

  close() {
    this.element.classList.remove('is-opened-dropdown')
  }

  closeOnClickOutside = (event) => {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
