
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
      .then((response) => response.text())
      .then((html) => {
        const pageMain = document.querySelector('.page-main')
        if (pageMain) pageMain.outerHTML = html
      })
      .catch((error) => console.error('削除に失敗しました', error))
  })
})
