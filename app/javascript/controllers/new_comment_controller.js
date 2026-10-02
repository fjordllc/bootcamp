import { Controller } from '@hotwired/stimulus'
import TextareaInitializer from 'textarea-initializer'

export default class extends Controller {
  static targets = ['inputBody']

  connect() {
    TextareaInitializer.initialize(`#${this.inputBodyTarget.id}`)
  }
}
