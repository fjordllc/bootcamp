import { get, destroy } from '@rails/request.js'
import { toggleDeleteButtonVisibility } from './bookmarks-delete-button-visibility'

document.addEventListener('DOMContentLoaded', () => {
  initializer()

  document.body.addEventListener('click', async (event) => {
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

      let pageToShow = newPageMain
      if (currentPage > 1 && newPageMain.querySelector('.o-empty-message')) {
        pageToShow = await fetchPageMain(currentPage - 1)
      }
      document.querySelector('.page-main').replaceWith(pageToShow)

      initializer(true)
    } catch (error) {
      console.warn(error)
      deleteButton.disabled = false
    }
  })
})

const fetchPageMain = async (page) => {
  const bookmarkUrl = `/current_user/bookmarks?page=${page}`
  const response = await get(bookmarkUrl, { responseKind: 'html' })
  const html = await response.text
  const parser = new DOMParser()
  const parsedDocument = parser.parseFromString(html, 'text/html')
  return parsedDocument.querySelector('.page-main')
}

const initializer = (deleteMode = false) => {
  const editButton = document.getElementById('bookmark_edit')
  const deleteButtons = document.getElementsByClassName(
    'js-bookmark-delete-button'
  )

  if (editButton && deleteButtons.length > 0) {
    editButton.checked = deleteMode
    toggleDeleteButtonVisibility(editButton, deleteButtons)

    editButton.removeEventListener('change', handleEditToggleChange)
    editButton.addEventListener('change', handleEditToggleChange)
  }
}

const handleEditToggleChange = () => {
  const editButton = document.getElementById('bookmark_edit')
  const deleteButtons = document.getElementsByClassName(
    'js-bookmark-delete-button'
  )
  toggleDeleteButtonVisibility(editButton, deleteButtons)
}
