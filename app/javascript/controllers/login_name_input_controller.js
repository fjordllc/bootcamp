import { Controller } from '@hotwired/stimulus'

// ユーザー名の形式を、送信前にその場で知らせる(重複は送信後にサーバーで確かめる)
export default class extends Controller {
  static targets = ['input', 'message']

  check() {
    const value = this.inputTarget.value
    const message = this.#problem(value)
    this.messageTarget.hidden = value === '' || message === null
    this.messageTarget.textContent = message || ''
  }

  #problem(value) {
    if (!/^[a-zA-Z0-9-]*$/.test(value)) {
      return '半角英数字と-（ハイフン）のみが使用できます。'
    }
    if (value.startsWith('-') || value.endsWith('-')) {
      return '先頭と最後にハイフンは使えません。'
    }
    if (value.includes('--')) return 'ハイフンを連続して使うことはできません。'
    if (value.length < 3)
      return `あと${3 - value.length}文字以上入力してください。`
    return null
  }
}
