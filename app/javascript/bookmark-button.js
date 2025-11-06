import { toast } from './vanillaToast'
import { get, post, destroy } from '@rails/request.js'

document.addEventListener('DOMContentLoaded', () => {
  const button = document.querySelector('#bookmark-button')
  if (!button) return
  const bookmarkableId = button.dataset.bookmarkableId
  const bookmarkableType = button.dataset.bookmarkableType
  const url = `/api/bookmarks.json?bookmarkable_type=${bookmarkableType}&bookmarkable_id=${bookmarkableId}`
  let bookmarkId = null
  let isBookmark = false

  const setLoading = (loading) => {
    button.disabled = loading
    if (loading) {
      button.dataset.loading = 'true'
      button.setAttribute('aria-busy', 'true')
    } else {
      delete button.dataset.loading
      button.removeAttribute('aria-busy')
    }
  }

  const bookmark = async () => {
    try {
      const response = await post(url)
      if (response.ok) {
        isBookmark = true
        const data = await response.json
        bookmarkId = data.id
        toast('Bookmarkしました！')
      } else {
        console.warn('Bookmarkに失敗しました。')
      }
    } catch (error) {
      console.warn(error)
    }
  }

  const unBookmark = async () => {
    try {
      const response = await destroy(`/api/bookmarks/${bookmarkId}`)
      if (response.ok) {
        isBookmark = false
        bookmarkId = null
        toast('ブックマークを削除しました')
      } else {
        console.warn('ブックマーク削除に失敗しました。')
      }
    } catch (error) {
      console.warn(error)
    }
  }

  const toggleButtonUI = () => {
    button.classList.toggle('is-active', isBookmark)
    button.classList.toggle('is-main', isBookmark)
    button.classList.toggle('is-inactive', !isBookmark)
    button.classList.toggle('is-muted', !isBookmark)
    button.setAttribute('aria-pressed', String(isBookmark))
    button.textContent = isBookmark ? 'Bookmark中' : 'Bookmark'
  }

  const fetchBookmark = async () => {
    try {
      setLoading(true)
      const response = await get(url)
      if (response.ok) {
        const data = await response.json
        if (data.bookmarks.length > 0) {
          bookmarkId = data.bookmarks[0].id
          isBookmark = true
        }
      } else {
        console.warn('ブックマークの読み込みに失敗しました')
      }
    } catch (error) {
      console.warn(error)
    } finally {
      toggleButtonUI()
      setLoading(false)
    }
  }

  button.addEventListener('click', async (e) => {
    e.preventDefault()
    if (button.dataset.loading === 'true') return
    setLoading(true)

    try {
      if (isBookmark) {
        await unBookmark()
      } else {
        await bookmark()
      }
    } catch (error) {
      console.warn(error)
    } finally {
      toggleButtonUI()
      setLoading(false)
    }
  })

  fetchBookmark()
})
