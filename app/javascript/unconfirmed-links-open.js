document.addEventListener('DOMContentLoaded', () => {
  const allOpenButton = document.querySelector('#js-shortcut-unconfirmed-links-open')
  if (allOpenButton) {
    allOpenButton.addEventListener('click', () => {
      var links = document.querySelectorAll('.thread-list-item .js-unconfirmed-link')
      links.forEach(link => {
        window.open(link.href, '_target', 'noopener')
      })
    })
  }
})
