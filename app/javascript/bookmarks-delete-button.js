import { destroy } from '@rails/request.js'
import { toggleDeleteButton } from './bookmarks-utils'

document.addEventListener('DOMContentLoaded', () => {

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

      const bookMarksEditButton = document.getElementById('bookmark_edit')
      const bookmarkDeleteButton = document.getElementsByClassName(
        'js-bookmark-delete-button'
      )

      if (bookMarksEditButton && bookmarkDeleteButton.length > 0) {
        bookMarksEditButton.checked = true
        toggleDeleteButton(bookMarksEditButton, bookmarkDeleteButton)
      }
    } catch (error) {
      console.warn(error)
    }
  })
})

const fetchPageMain = async (page) => {
  const bookmarkUrl = `/current_user/bookmarks?page=${page}`
  const html = await fetch(bookmarkUrl).then((res) => res.text())
  const parser = new DOMParser()
  const parsedDocument = parser.parseFromString(html, 'text/html')
  return parsedDocument.querySelector('.page-main')
}
