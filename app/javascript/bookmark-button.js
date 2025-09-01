import fetcher from './fetcher'
import { toast } from './vanillaToast'
import { post, destroy } from '@rails/request.js'

class BookmarkButton {
  constructor(element) {
    this.element = element
    this.bookmarkableId = element.dataset.bookmarkableId
    this.bookmarkableType = element.dataset.bookmarkableType
    this.bookmarkUrl = `/api/bookmarks.json?bookmarkable_type=${this.bookmarkableType}&bookmarkable_id=${this.bookmarkableId}`

    this.isBookmark = false
    this.bookmarkId = null
    this.isLoading = false

    this.init()
  }

  async init() {
    this.setLoadingState(true)
    this.element.addEventListener('click', (e) => this.handleClick(e))

    try {
      await this.fetchBookmarkStatus()
    } catch (error) {
      console.error('初期データの取得に失敗しました:', error)
      this.setLoadingState(false)
    }
  }

  async fetchBookmarkStatus() {
    try {
      const data = await fetcher(this.bookmarkUrl)
      this.isBookmark = data.bookmarks.length > 0
      if (data.bookmarks.length > 0) {
        this.bookmarkId = data.bookmarks[0].id
      }
      this.setLoadingState(false)
      this.updateUI()
    } catch (error) {
      console.error('ブックマーク状態の取得に失敗しました:', error)
      this.setLoadingState(false)
    }
  }

  setLoadingState(loading) {
    this.isLoading = loading
    this.element.disabled = loading
    this.element.setAttribute('aria-busy', String(loading))
    if (loading) {
      this.element.dataset.loading = 'true'
      this.element.className =
        'a-bookmark-button a-button is-sm is-block is-inactive is-muted'
      this.element.textContent = 'Bookmark'
    } else {
      delete this.element.dataset.loading
      this.updateUI()
    }
  }

  updateUI() {
    if (this.isLoading) return

    const bookmarkLabel = this.isBookmark ? 'Bookmark中' : 'Bookmark'
    const classes = this.isBookmark
      ? 'a-bookmark-button a-button is-sm is-block is-active is-main'
      : 'a-bookmark-button a-button is-sm is-block is-inactive is-muted'

    this.element.className = classes
    this.element.textContent = bookmarkLabel
    this.element.setAttribute('aria-pressed', String(this.isBookmark))
  }

  async handleClick(e) {
    e.preventDefault()
    if (this.isLoading) return

    if (this.isBookmark) {
      await this.unbookmark()
    } else {
      await this.bookmark()
    }
  }

  async bookmark() {
    try {
      this.setLoadingState(true)
      const response = await post(this.bookmarkUrl, {
        contentType: 'application/json'
      })

      if (response.ok) {
        this.isBookmark = true
        const data = await response.json
        this.bookmarkId = data.id
        toast('Bookmarkしました！')
      } else {
        console.warn('Bookmarkに失敗しました。')
      }
    } catch (error) {
      console.warn('Bookmark処理中にエラーが発生しました:', error)
    } finally {
      this.setLoadingState(false)
    }
  }

  async unbookmark() {
    if (!this.bookmarkId) return

    try {
      this.setLoadingState(true)

      const response = await destroy(`/api/bookmarks/${this.bookmarkId}`)

      if (response.ok) {
        this.isBookmark = false
        this.bookmarkId = null
        toast('ブックマークを削除しました')
      } else {
        console.warn('ブックマーク削除に失敗しました。')
      }
    } catch (error) {
      console.warn('ブックマーク削除中にエラーが発生しました:', error)
    } finally {
      this.setLoadingState(false)
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const bookmarkButtons = document.querySelectorAll('[data-bookmark-button]')
  bookmarkButtons.forEach((button) => {
    const bookmarkButton = new BookmarkButton(button)
    button._bookmarkButtonInstance = bookmarkButton
  })
})
