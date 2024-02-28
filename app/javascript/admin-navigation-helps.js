document.addEventListener('DOMContentLoaded', () => {
  const dropdownMenu = document.querySelector('.js-admin-helps')
  const dropdownList = document.querySelector('.js-admin-helps__target')

  dropdownList.style.display = 'none'

  document.addEventListener('click', (event) => {
    if (!dropdownMenu.contains(event.target)) {
      dropdownList.style.display = 'none'
    }
  })

  dropdownMenu.addEventListener('click', () => {
    if (dropdownList.style.display === 'none') {
      dropdownList.style.display = 'block'
    } else {
      dropdownList.style.display = 'none'
    }
  })
})
