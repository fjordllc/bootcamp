import { Controller } from '@hotwired/stimulus'
import { FetchRequest } from '@rails/request.js'

export default class extends Controller {
  followOrNot(e) {
    e.preventDefault()
    const isFollowing = e.params.following
    const userId = e.params.id
    const isWatching = e.params.watching
    const method = isFollowing ? 'PATCH' : 'POST'
    const url = isFollowing
      ? `/api/followings/${userId}?watch=${isWatching}`
      : `/api/followings?watch=${isWatching}`
    const params = {
      id: userId
    }
    this.#fetchRequest(url, method, params, 'フォロー処理に失敗しました')
  }

  unFollow(e) {
    e.preventDefault()
    const userId = e.params.id
    if (!userId) {
      console.error('ユーザーIDが取得できませんでした。')
      return
    }
    const url = `/api/followings/${userId}`
    const params = {
      id: userId
    }
    this.#fetchRequest(url, 'DELETE', params, 'フォロー解除処理に失敗しました')
  }

  async #fetchRequest(url, method, params, errorMessage) {
    const buttons = this.element.querySelectorAll('button')
    buttons.forEach((button) => {
      button.disabled = true
    })
    try {
      const request = new FetchRequest(method, url, {
        responseKind: 'html',
        body: JSON.stringify(params)
      })
      const response = await request.perform()
      if (response.ok) {
        const html = await response.html
        this.element.outerHTML = html
      } else {
        alert(errorMessage)
      }
    } catch {
      alert(errorMessage)
    } finally {
      buttons.forEach((button) => {
        button.disabled = false
      })
    }
  }
}
