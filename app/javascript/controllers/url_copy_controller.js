import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  initialize() {
    this.resetTimer = null
  }

  connect() {
    this.#reset()
  }

  disconnect() {
    this.#reset()
  }

  async copy() {
    if (!navigator.clipboard) return

    const url = window.location.href

    try {
      await navigator.clipboard.writeText(url)
    } catch (error) {
      console.error(error)
      return
    }

    if (!this.element.isConnected) return

    clearTimeout(this.resetTimer)
    this.element.classList.add('is-active')

    this.resetTimer = setTimeout(() => {
      this.#reset()
    }, 4000)
  }

  #reset() {
    clearTimeout(this.resetTimer)
    this.resetTimer = null
    this.element.classList.remove('is-active')
  }
}
