import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.toggleHandler = this.toggle.bind(this)
    document.addEventListener('click', this.toggleHandler)
  }

  disconnect() {
    document.removeEventListener('click', this.toggleHandler)
  }

  toggle(e) {
    if (this.element.contains(e.target)) {
      return
    }

    if (this.element.hasAttribute('open')) {
      this.element.removeAttribute('open')
    }
  }

  disableButtons() {
    this.element.querySelectorAll('button').forEach((button) => {
      button.disabled = true
    })
  }

  checkError(e) {
    this.element.querySelectorAll('button').forEach((button) => {
      button.disabled = false
    })

    if (!e.detail.success) {
      alert('フォロー処理に失敗しました')
    }
  }
}
