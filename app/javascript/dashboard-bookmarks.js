import { get, destroy } from '@rails/request.js'
import { toggleDeleteButtonVisibility } from './bookmarks-delete-button-visibility'
import { toast } from './vanillaToast.js'

document.addEventListener('DOMContentLoaded', () => {
  const bookmarksContainer = document.querySelector('.dashboard-bookmarks')
  if (!bookmarksContainer) return

  const editModeToggle = bookmarksContainer.querySelector('#bookmark_edit')
  const deleteButtons = bookmarksContainer.querySelectorAll(
    '.js-bookmark-delete-button'
  )

  if (editModeToggle && deleteButtons.length) {
    toggleDeleteButtonVisibility(editModeToggle, deleteButtons)
  }

  if (editModeToggle) {
    editModeToggle.addEventListener('change', () => {
      const deleteButtons = bookmarksContainer.querySelectorAll(
        '.js-bookmark-delete-button'
      )
      toggleDeleteButtonVisibility(editModeToggle, deleteButtons)
    })
  }

  bookmarksContainer.addEventListener('click', async (event) => {
    const deleteButton = event.target.closest('.bookmark-delete-button')
    if (!deleteButton) return

    const url = deleteButton.dataset.url
    try {
      const response = await destroy(url)
      if (response.ok) {
        toast('ブックマークを削除しました。')
        console.log(response)
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

function replaceBookmarks(containerElement, html) {
  const tmpContainer = document.createElement('div')
  tmpContainer.innerHTML = html
  const newList = tmpContainer.querySelector('.card-list')
  const newFooter = tmpContainer.querySelector('.card-footer')

  containerElement.querySelector('.card-list').replaceWith(newList)
  containerElement.querySelector('.card-footer').replaceWith(newFooter)
}
