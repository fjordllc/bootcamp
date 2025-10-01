import { toggleDeleteButton } from './bookmarks-utils'

document.addEventListener('DOMContentLoaded', () => {
  const bookMarksEditButton = document.getElementById('bookmark_edit')
  const bookmarkDeleteButton = document.getElementsByClassName(
    'js-bookmark-delete-button'
  )

  if (bookMarksEditButton && bookmarkDeleteButton.length > 0) {
    for (const button of bookmarkDeleteButton) {
      button.style.display = 'none'
    }

    toggleDeleteButton(bookMarksEditButton, bookmarkDeleteButton)
  }
})
