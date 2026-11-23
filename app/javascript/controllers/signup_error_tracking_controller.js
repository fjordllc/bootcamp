import { Controller } from '@hotwired/stimulus'

// 参加登録で入力エラーになった項目名を Google Analytics に送る。入力値は送らない
export default class extends Controller {
  static values = { fields: Array }

  connect() {
    if (typeof window.gtag !== 'function') return

    this.fieldsValue.forEach((field) => {
      window.gtag('event', 'signup_error', { field })
    })
  }
}
