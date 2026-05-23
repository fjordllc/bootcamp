import { get, destroy } from '@rails/request.js'
import { toggleDeleteButtonVisibility } from './bookmarks-delete-button-visibility'
import { toast } from './vanillaToast.js'

document.addEventListener('DOMContentLoaded', () => {
  const bookmarksContainer = document.querySelector('.dashboard-bookmarks')
  if (!bookmarksContainer) return

  const editToggle = bookmarksContainer.querySelector('#bookmark_edit')
  setEditMode(bookmarksContainer, editToggle)

  if (editToggle) {
    editToggle.addEventListener('change', () => {
      setEditMode(bookmarksContainer, editToggle)
    })
  }

  bookmarksContainer.addEventListener('click', async (event) => {
    const deleteButton = event.target.closest(
      '.dashboard-bookmark-delete-button'
    )
    if (!deleteButton) return

    const url = deleteButton.dataset.url
    try {
      const response = await destroy(url)
      if (response.ok) {
        toast('ブックマークを削除しました。')
      } else {
        throw new Error('Failed to delete')
      }
    } catch (error) {
      console.warn(error)
    }

    const response = await get('/current_user/bookmarks/dashboard', {
      responseKind: 'html'
    })
    const html = await response.text

    if (html.trim().length === 0) {
      bookmarksContainer.remove()
    } else {
      replaceBookmarks(bookmarksContainer, html)
    }
  })
})

window.addEventListener('pageshow', () => {
  const bookmarksContainer = document.querySelector('.dashboard-bookmarks')
  if (!bookmarksContainer) return

  const editToggle = bookmarksContainer.querySelector('#bookmark_edit')
  editToggle.checked = false
  setEditMode(bookmarksContainer, editToggle)
})

function setEditMode(container, editToggle) {
  if (!editToggle) return

  const deleteButtons = container.querySelectorAll('.js-bookmark-delete-button')
  toggleDeleteButtonVisibility(editToggle, deleteButtons)
}

function replaceBookmarks(containerElement, html) {
  const tempContainer = document.createElement('div')
  tempContainer.innerHTML = html
  const newList = tempContainer.querySelector('.card-list')
  const newFooter = tempContainer.querySelector('.card-footer')

  containerElement.querySelector('.card-list').replaceWith(newList)
  containerElement.querySelector('.card-footer').replaceWith(newFooter)
}
