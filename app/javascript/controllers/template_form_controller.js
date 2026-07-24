import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "description", "destroy", "message" ]

  clear(event) {
    event.preventDefault()
    this.descriptionTarget.value = ""
    this.destroyTarget.value = "1"
    this.messageTarget.classList.remove("hidden")
  }
}
