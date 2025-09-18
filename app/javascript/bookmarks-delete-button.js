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

      console.log(response)

      if (!response.ok) {
        throw new Error(`削除に失敗しました。`)
      }

      const html = await response.text
      document.querySelector('.page-main').outerHTML = html
    } catch (error) {
      console.warn(error)
    }
  })
})
