import { Controller } from '@hotwired/stimulus'

// ひらがなで入力されたフリガナを、カタカナに直す
export default class extends Controller {
  convert() {
    const converted = this.element.value.replace(/[ぁ-ゖ]/g, (char) =>
      String.fromCharCode(char.charCodeAt(0) + 0x60)
    )
    if (converted !== this.element.value) this.element.value = converted
  }
}
