export function toggleDeleteButton(bookMarksEditButton, bookmarkDeleteButton) {
  bookMarksEditButton.addEventListener('click', () => {
    const displayStyle = bookMarksEditButton.checked ? 'block' : 'none'
    for (const button of bookmarkDeleteButton) {
    button.style.display = displayStyle
  }
  })
}
