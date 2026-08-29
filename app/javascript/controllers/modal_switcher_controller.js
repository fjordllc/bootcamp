import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modal']

  toggle() {
    this.modalTarget.classList.toggle('is-shown')
  }
}
