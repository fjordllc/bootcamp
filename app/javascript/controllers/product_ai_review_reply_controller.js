import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['text', 'status']

  async copy() {
    try {
      await navigator.clipboard.writeText(this.textTarget.value)
      this.statusTarget.textContent = 'コピーしました。'
    } catch {
      this.textTarget.focus()
      this.textTarget.select()
      this.statusTarget.textContent =
        '自動でコピーできませんでした。選択された返信案を手動でコピーしてください。'
    }
  }
}
