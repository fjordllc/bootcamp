document.addEventListener('DOMContentLoaded', () => {
  const bookMarksEditButton = document.getElementById('bookmark_edit')
  const bookmarkDeleteButton = document.getElementsByClassName('bookmark-delete-button')
  if (bookMarksEditButton && bookmarkDeleteButton) {
    for (let i = 0; i < bookmarkDeleteButton.length; i++) {
      bookmarkDeleteButton[i].style.visibility = 'hidden'
    }
  }

  bookMarksEditButton.addEventListener('click', () => {
    if (bookMarksEditButton.checked) {
      for (let i = 0; i < bookmarkDeleteButton.length; i++) {
        bookmarkDeleteButton[i].style.visibility = 'visible'
      }
    } else {
      for (let i = 0; i < bookmarkDeleteButton.length; i++) {
        bookmarkDeleteButton[i].style.visibility = 'hidden'
      }
    }
  })
})
