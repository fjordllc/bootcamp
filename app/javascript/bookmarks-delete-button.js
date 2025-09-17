
document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('click', (event) => {
    const deleteButton = event.target.closest('.bookmark-delete-button')
    if (!deleteButton) return

    event.preventDefault()
    
    const url = deleteButton.dataset.url

    fetch(url, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
          .content,
        Accept: 'text/html'
      }
    })
      .then(() => {
        const cardListItems = document.querySelectorAll('.card-list-item')

        if (cardListItems.length === 1) {
          deleteButton.closest('.card-list-item').remove()

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
          deleteButton.closest('.card-list-item').remove()
        }
      })

      .catch((error) => console.error('削除に失敗しました', error))
  })
})
