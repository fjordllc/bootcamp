function copyUrl() {
  const url = window.location.href
  navigator.clipboard
    .writeText(url)
    .then(() => {
      const button = document.querySelector('.a-copy-button')
      button.classList.add('is-active')
      setTimeout(() => {
        button.classList.remove('is-active')
      }, 4000)
    })
    .catch((err) => {
      console.error(err)
    })
}

window.copyUrl = copyUrl
