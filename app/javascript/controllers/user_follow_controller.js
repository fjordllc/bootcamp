import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  closeOnOutsideClick(e) {
    if (this.element.contains(e.target)) return

    this.element.open = false
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
