document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const checkbox = document.querySelector('.js-mentor-mode__trigger')
  const body = document.body
  if (!checkbox) return
  if (localStorage.getItem('mentor-mode')) {
    checkbox.checked = false
    body.classList.remove('is-mentor-mode')
  } else {
    checkbox.checked = true
    body.classList.add('is-mentor-mode')
  }
  checkbox.addEventListener('click', () => {
    if (checkbox.checked) {
      localStorage.removeItem('mentor-mode')
      body.classList.add('is-mentor-mode')
    } else {
      localStorage.setItem('mentor-mode', 'off')
      body.classList.remove('is-mentor-mode')
    }
  })
})
