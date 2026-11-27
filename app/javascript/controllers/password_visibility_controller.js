import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'button']

  toggle() {
    const hidden = this.inputTarget.type === 'password'
    this.inputTarget.type = hidden ? 'text' : 'password'
    this.buttonTarget.textContent = hidden ? '隠す' : '表示'
  }
}
