import { Controller } from '@hotwired/stimulus'
import { get, post, destroy } from '@rails/request.js'
import { toast } from 'vanillaToast'

export default class extends Controller {
  static values = {
    bookmarkableId: Number,
    bookmarkableType: String
  }

  static classes = ['active', 'main', 'inactive', 'muted']

  connect() {
    this.bookmarkId = null
    this.isBookmark = false
    this.fetchBookmark()
  }

  async fetchBookmark() {
    this.setLoading(true)
    try {
      const url = this.apiUrl
      const response = await get(url)
      if (response.ok) {
        const data = await response.json
        if (data.bookmarks.length > 0) {
          this.bookmarkId = data.bookmarks[0].id
          this.isBookmark = true
        }
      }
    } catch (error) {
      console.warn(error)
    } finally {
      this.toggleButtonUI()
      this.setLoading(false)
    }
  }

  async toggle(event) {
    event.preventDefault()
    if (this.element.dataset.loading === 'true') return
    this.setLoading(true)

    try {
      if (this.isBookmark) {
        await this.unBookmark()
      } else {
        await this.bookmark()
      }
    } catch (error) {
      console.warn(error)
    } finally {
      this.toggleButtonUI()
      this.setLoading(false)
    }
  }

  async bookmark() {
    try {
      const response = await post(this.apiUrl)
      if (response.ok) {
        this.isBookmark = true
        const data = await response.json
        this.bookmarkId = data.id
        toast('Bookmarkしました！')
        window.dispatchEvent(new CustomEvent('bookmark:changed'))
      }
    } catch (error) {
      console.warn(error)
    }
  }

  async unBookmark() {
    try {
      const response = await destroy(`/api/bookmarks/${this.bookmarkId}`)
      if (response.ok) {
        this.isBookmark = false
        this.bookmarkId = null
        toast('ブックマークを削除しました')
        window.dispatchEvent(new CustomEvent('bookmark:changed'))
      }
    } catch (error) {
      console.warn(error)
    }
  }

  setLoading(loading) {
    this.element.disabled = loading
    if (loading) {
      this.element.dataset.loading = 'true'
      this.element.setAttribute('aria-busy', 'true')
    } else {
      delete this.element.dataset.loading
      this.element.removeAttribute('aria-busy')
    }
  }

  toggleButtonUI() {
    this.element.classList.toggle(this.activeClass, this.isBookmark)
    this.element.classList.toggle(this.mainClass, this.isBookmark)
    this.element.classList.toggle(this.inactiveClass, !this.isBookmark)
    this.element.classList.toggle(this.mutedClass, !this.isBookmark)
    this.element.setAttribute('aria-pressed', String(this.isBookmark))
    this.element.textContent = this.isBookmark ? 'Bookmark中' : 'Bookmark'
  }

  get apiUrl() {
    return `/api/bookmarks.json?bookmarkable_type=${this.bookmarkableTypeValue}&bookmarkable_id=${this.bookmarkableIdValue}`
  }
}
