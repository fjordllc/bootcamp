document.addEventListener('DOMContentLoaded', () => {
  const dropdownMenu = document.querySelector('.js-admin-helps')
  const dropdownList = document.querySelector('.js-admin-helps__target')
  const dropdownListParent = document.querySelector('.global-nav__inner')

  dropdownList.style.display = 'none'

  dropdownList.style.position = 'absolute'
  dropdownList.style.top = '0'
  dropdownList.style.left = '100%'

  document.addEventListener('click', (event) => {
    if (!dropdownMenu.contains(event.target)) {
      dropdownList.style.display = 'none'
      dropdownListParent.style.overflowY = 'auto'
    }
  })

  dropdownMenu.addEventListener('click', () => {
    if (dropdownList.style.display === 'none') {
      dropdownList.style.display = 'block'
      dropdownListParent.style.overflowY = 'visible'
    } else {
      dropdownList.style.display = 'none'
      dropdownListParent.style.overflowY = 'auto'
    }
  })
})
