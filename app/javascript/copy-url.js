function setupCopyUrl() {
  const button = document.querySelector('.a-copy-button')

  if (!button || button.dataset.copyUrlInitialized === 'true') {
    return
  }

  button.dataset.copyUrlInitialized = 'true'
  button.addEventListener('click', () => {
    const url = window.location.href
    navigator.clipboard
      .writeText(url)
      .then(() => {
        button.classList.add('is-active')
        setTimeout(() => {
          button.classList.remove('is-active')
        }, 4000)
      })
      .catch((err) => {
        console.error(err)
      })
  })
}

document.addEventListener('turbo:load', setupCopyUrl)
document.addEventListener('DOMContentLoaded', setupCopyUrl)
setupCopyUrl()
