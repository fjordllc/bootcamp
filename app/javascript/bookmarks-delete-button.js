import { destroy } from '@rails/request.js'

document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('click', (event) => {
    const deleteButton = event.target.closest('.bookmark-delete-button')
    if (!deleteButton) return

    event.preventDefault()

    deleteBookmark(deleteButton)
  })
})

async function deleteBookmark(deleteButton) {
  const url = deleteButton.dataset.url
  try {
    const response = await destroy(url, {
      responseKind: 'html',
      headers: { Accept: 'text/html' }
    })

    if (!response.ok) {
      throw new Error(`削除に失敗しました。`)
    }

    const cardListItems = document.querySelectorAll('.card-list-item')
    const cardListItem = deleteButton.closest('.card-list-item')

    if (cardListItems.length === 1) {
      cardListItem.remove()
      const pageBody = document.querySelector('.page-body')
      if (pageBody) {
        pageBody.innerHTML = `
          <div class="o-empty-message">
            <div class="o-empty-message__icon">
              <i class="fa-regular fa-face-sad-tear"></i>
              <p class="o-empty-message__text">ブックマークはまだありません。</p>
            </div>
          </div>
        `
      }
    } else {
      cardListItem.remove()
    }
  } catch (error) {
    console.warn(error)
  }
}
