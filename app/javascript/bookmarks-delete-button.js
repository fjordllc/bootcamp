import { destroy } from '@rails/request.js'

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
      bookMarksEditButton.checked = true
      if (bookMarksEditButton && bookmarkDeleteButton) {
        for (let i = 0; i < bookmarkDeleteButton.length; i++) {
          bookmarkDeleteButton[i].style.display = 'block'
        }

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
    } catch (error) {
      console.warn(error)
    }
  })
})
