import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['description', 'message', 'preview']

  clear(event) {
    event.preventDefault()

    this.descriptionTarget.value = ''
    this.previewTarget.textContent = ''
    this.updateMessage()
  }

  updateMessage() {
    this.messageTarget.classList.toggle(
      'hidden',
      this.descriptionTarget.value.trim() !== ''
    )
  }
}
