import { Controller } from '@hotwired/stimulus'
import { get } from '@rails/request.js'

export default class extends Controller {
  static targets = ['count']

  async refresh() {
    if (!this.hasCountTarget) return
    try {
      const response = await get('/api/bookmarks.json?per=1', {
        responseKind: 'json'
      })
      if (response.ok) {
        const data = await response.json
        this.countTarget.textContent = `（${data.unpagedBookmarks.length}）`
      }
    } catch (error) {
      console.warn(error)
    }
  }
}
