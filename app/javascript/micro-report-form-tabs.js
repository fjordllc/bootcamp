document.addEventListener('DOMContentLoaded', function () {
  const tabLinks = document.querySelectorAll('.js-tab-link')
  const tabPanes = document.querySelectorAll('.js-tab-pane')

  tabLinks.forEach((tabLink) => {
    tabLink.addEventListener('click', function (event) {
      event.preventDefault()

      tabLinks.forEach((l) => l.classList.remove('is-active'))
      tabPanes.forEach((p) => p.classList.add('hidden'))

      tabLink.classList.add('is-active')
      const targetId = tabLink.dataset.target
      document.getElementById(targetId).classList.remove('hidden')
    })
  })
})
