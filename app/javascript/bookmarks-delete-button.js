import { destroy } from '@rails/request.js'
import { toggleDeleteButton } from './bookmarks-utils'

document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('click', async (event) => {
    const deleteButton = event.target.closest('.bookmark-delete-button')
    if (!deleteButton) return

    event.preventDefault()

    const url = deleteButton.dataset.url

    try {
      const response = await destroy(url, {
        responseKind: 'html',
        headers: { Accept: 'text/html' }
      })

      if (!response.ok) {
        throw new Error(`削除に失敗しました。(ステータス: ${response.status})`)
      }

      const html = await response.text
      console.log(html)
      document.querySelector('.page-main').innerHTML = html

      const bookMarksEditButton = document.getElementById('bookmark_edit')
      const bookmarkDeleteButton = document.getElementsByClassName(
        'js-bookmark-delete-button'
      )
      if (bookMarksEditButton && bookmarkDeleteButton) {
        bookMarksEditButton.checked = true

        for (let i = 0; i < bookmarkDeleteButton.length; i++) {
          bookmarkDeleteButton[i].style.display = 'block'
        }
        toggleDeleteButton(bookMarksEditButton, bookmarkDeleteButton)
      }
    } catch (error) {
      console.warn(error)
    }
  })
})
