export default class {
  async render(selector) {
    const textareas = document.querySelectorAll(selector)
    if (textareas.length === 0) {
      return null
    }
    await this._callbackFunc()
    Array.from(textareas).forEach((textarea) => {
      textarea.addEventListener('input', () => {
        this._callbackFunc()
      })
    })
  }

  async _callbackFunc() {
    const DEFAULT_PROFILE_IMAGE_PATH = '/images/users/avatars/default.png'
    const elements = document.getElementsByClassName('js-user-icon')

    const promises = Array.from(elements).map(async (element) => {
      const loginName = element.dataset.user
      let imageUrl
      if (process.env.NODE_ENV === 'production') {
        imageUrl = `https://storage.googleapis.com/rira_test/icon/${loginName}`
      } else {
        imageUrl = `/storage/ic/on/icon/${loginName}`
      }

      try {
        await this._loadImage(imageUrl)
        element.src = imageUrl
      } catch (error) {
        element.src = DEFAULT_PROFILE_IMAGE_PATH
      }
    })

    await Promise.all(promises)
  }

  _loadImage(url) {
    return new Promise((resolve, reject) => {
      const img = new Image()
      img.src = url
      img.onload = () => resolve(img)
      img.onerror = reject
    })
  }
}
