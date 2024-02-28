document.addEventListener('DOMContentLoaded', () => {
  const dropdownMenus = document.querySelectorAll('.js-header-dropdown')

  document.addEventListener('click', (event) => {
    dropdownMenus.forEach((dropdownMenu) => {
      if (!dropdownMenu.contains(event.target)) {
        dropdownMenu.classList.remove('is-opened-dropdown')
      }
    })
  })

  dropdownMenus.forEach((dropdownMenu) => {
    dropdownMenu.addEventListener('click', () => {
      if (dropdownMenu.classList.contains('is-opened-dropdown')) {
        dropdownMenu.classList.remove('is-opened-dropdown')
      } else {
        dropdownMenu.classList.add('is-opened-dropdown')
      }
    })
  })
})
