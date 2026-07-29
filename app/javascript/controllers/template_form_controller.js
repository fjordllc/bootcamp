import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['description', 'destroy', 'message', 'preview']

  clear(event) {
    event.preventDefault()

    this.descriptionTarget.value = ''
    this.previewTarget.textContent = ''
    this.destroyTarget.value = '1'
    this.messageTarget.classList.remove('hidden')
  }
}
