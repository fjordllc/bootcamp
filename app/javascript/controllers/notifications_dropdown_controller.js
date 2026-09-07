import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['dropdown', 'button']

  toggle() {
    const isHidden = this.dropdownTarget.classList.toggle('is-hidden')
    this.buttonTarget.setAttribute('aria-expanded', String(!isHidden))

    if (!isHidden) {
      this.element.dispatchEvent(
        new CustomEvent('notifications-dropdown:opened')
      )
    }
  }

  close() {
    this.dropdownTarget.classList.add('is-hidden')
    this.buttonTarget.setAttribute('aria-expanded', 'false')
  }

  closeOnEscape = (event) => {
    if (event.key === 'Escape') {
      this.close()
    }
  }
}
