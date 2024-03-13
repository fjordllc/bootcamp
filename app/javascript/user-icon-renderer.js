export default class {
  constructor(element) {
    if (typeof element === 'string') {
      const textareas = document.querySelectorAll(element)
      if (textareas.length === 0) {
        return null
      }
      this.textareas = textareas
    } else {
      this.textareas = element
    }
  }

  async render() {
    const response = await fetch('/api/user_icon_urls', {
      method: 'GET',
      credentials: 'same-origin',
      headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
    this.urls = await response.json()
    this._callbackFunc()
    Array.from(this.textareas).forEach((textarea) => {
      textarea.addEventListener('input', () => {
        this._callbackFunc()
      })
    })
  }

  _callbackFunc() {
    const DEFAULT_PROFILE_IMAGE_PATH = '/images/users/avatars/default.png'
    const elements = document.getElementsByClassName('js-user-icon')
    Array.from(elements).forEach((element) => {
      const loginName = element.dataset.user
      if (element.src === '') element.src = this.urls[loginName]
      if (this.urls[loginName] === undefined)
        element.src = DEFAULT_PROFILE_IMAGE_PATH
    })
  }
}
