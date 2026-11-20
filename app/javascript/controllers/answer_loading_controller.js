import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['placeholder', 'content']

  connect() {
    // Reveal the answers after their Stimulus controllers have connected.
    this.frame = requestAnimationFrame(() => {
      this.placeholderTarget.classList.add('is-hidden')
      this.contentTarget.classList.remove('is-hidden')
    })
  }

  disconnect() {
    cancelAnimationFrame(this.frame)
  }

  reset() {
    cancelAnimationFrame(this.frame)
    this.placeholderTarget.classList.remove('is-hidden')
    this.contentTarget.classList.add('is-hidden')
  }
}
