document.addEventListener('DOMContentLoaded', () => {
  const button = document.querySelector('.a-copy-button')

  if (button) {
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
})
