document.addEventListener('DOMContentLoaded', () => {
  const allOpenButton = document.querySelector(
    '#js-shortcut-unconfirmed-links-open'
  )
  if (allOpenButton) {
    allOpenButton.addEventListener('click', () => {
      const links = document.querySelectorAll(
        '.card-list-item .js-unconfirmed-link'
      )
      links.forEach((link) => {
        window.open(link.href, '_blank', 'noopener')
      })
      setTimeout(() => {
        location.reload()
      }, 100)
    })
  }
})
