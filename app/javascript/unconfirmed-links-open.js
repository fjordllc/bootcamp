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
      if (links.length > 0) {
        setTimeout(() => {
          location.reload()
        }, 100)
      }
    })
  }
})
