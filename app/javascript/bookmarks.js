import { get, destroy } from '@rails/request.js'
import { toggleDeleteButtonVisibility } from './bookmarks-delete-button-visibility'

const EDIT_MODE_KEY = 'bookmark_edit_mode'
const DELETE_BUTTON_CLASS = 'js-bookmark-delete-button'

document.addEventListener('DOMContentLoaded', () => {
  const editButton = document.getElementById('bookmark_edit')
  const pageBody = document.querySelector('.page-body')
  if (!pageBody) return

  const savedValue = sessionStorage.getItem(EDIT_MODE_KEY)
  const savedMode = savedValue === 'true'
  initialize(savedMode)

  if (editButton) {
    editButton.addEventListener('change', () => {
      const deleteButtons = document.getElementsByClassName(DELETE_BUTTON_CLASS)
      toggleDeleteButtonVisibility(editButton, deleteButtons)
      sessionStorage.setItem(EDIT_MODE_KEY, editButton.checked)
    })
  }

  document.addEventListener('click', async (event) => {
    const deleteButton = event.target.closest('.bookmark-delete-button')
    if (!deleteButton) return

    deleteButton.disabled = true

    try {
      const url = deleteButton.dataset.url
      const response = await destroy(url)

      if (!response.ok) {
        throw new Error(`削除に失敗しました。(ステータス: ${response.status})`)
      }

      const params = new URLSearchParams(location.search)
      const currentPage = parseInt(params.get('page') || '1', 10)
      const newPageMain = await fetchPageMain(currentPage)

      // 空ページの場合は1ページ前にフォールバック
      let pageToShow = newPageMain
      if (currentPage > 1 && newPageMain.querySelector('.o-empty-message')) {
        pageToShow = await fetchPageMain(currentPage - 1)
      }
      document.querySelector('.page-body').replaceWith(pageToShow)

      const savedModeAfterDelete =
        sessionStorage.getItem(EDIT_MODE_KEY) === 'true'
      initialize(savedModeAfterDelete)
    } catch (error) {
      console.warn(error)
      deleteButton.disabled = false
    }
  })
})

window.addEventListener('beforeunload', () => {
  const isBookmarkPage = location.pathname.includes('/current_user/bookmarks')
  if (!isBookmarkPage) {
    sessionStorage.removeItem(EDIT_MODE_KEY)
  }
})

const fetchPageMain = async (page) => {
  const bookmarkUrl = `/current_user/bookmarks?page=${page}`
  const response = await get(bookmarkUrl, { responseKind: 'html' })
  const html = await response.text
  const parser = new DOMParser()
  const parsedDocument = parser.parseFromString(html, 'text/html')
  return parsedDocument.querySelector('.page-body')
}

const initialize = (deleteMode = false) => {
  const editButton = document.getElementById('bookmark_edit')
  const deleteButtons = document.getElementsByClassName(DELETE_BUTTON_CLASS)

  if (editButton && deleteButtons.length > 0) {
    editButton.checked = deleteMode
    toggleDeleteButtonVisibility(editButton, deleteButtons)
  }
}
