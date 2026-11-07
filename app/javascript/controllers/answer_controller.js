import { Controller } from '@hotwired/stimulus'
import initializeAnswer from 'initializeAnswer'

export default class extends Controller {
  connect() {
    this.cleanup = initializeAnswer(this.element)
    if (location.hash === `#${this.element.id}`) {
      this.scrollFrame = requestAnimationFrame(() => {
        this.scrollFrame = requestAnimationFrame(() => {
          this.element.scrollIntoView({ behavior: 'instant' })
        })
      })
    }
  }

  disconnect() {
    cancelAnimationFrame(this.scrollFrame)
    this.cleanup?.()
  }
}
