export function toggleDeleteButton(bookMarksEditButton, bookmarkDeleteButton) {
  bookMarksEditButton.addEventListener('click', () => {
    if (bookMarksEditButton.checked) {
      for (let i = 0; i < bookmarkDeleteButton.length; i++) {
        bookmarkDeleteButton[i].style.display = 'block'
      }
    } else {
      for (let i = 0; i < bookmarkDeleteButton.length; i++) {
        bookmarkDeleteButton[i].style.display = 'none'
      }
    }
  })
}
