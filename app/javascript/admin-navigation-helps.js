document.addEventListener('DOMContentLoaded', () => {
  const dropdownMenu = document.querySelector('.js-admin-helps')
  const dropdownList = document.querySelector('.js-admin-helps__target')
  const dropdownListParent = document.querySelector('.header-links__link')

  dropdownList.style.display = 'none'

  dropdownList.style.position = 'absolute'
  dropdownList.style.top = '100%'
  dropdownList.style.right = '0%'

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
