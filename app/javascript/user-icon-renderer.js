export default class {
  async render(selector) {
    const textareas = document.querySelectorAll(selector)
    const response = await fetch('/api/user_icon_urls', {
      method: 'GET',
      credentials: 'same-origin',
      headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
    this.urls = await response.json()
    this._callbackFunc()
    Array.from(textareas).forEach((textarea) => {
      textarea.addEventListener('input', () => {
        this._callbackFunc()
      })
    })
  }

  _callbackFunc() {
    const elements = document.getElementsByClassName('js-user-icon')
    Array.from(elements).forEach((element) => {
      const loginName = element.dataset.user
      element.src = this.urls[loginName]
    })
  }
}
