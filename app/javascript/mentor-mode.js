document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const checkboxMentorMode = document.querySelector('.js-mentor-mode__trigger')
  const jsMentorModeClass = document.body
  if (!checkboxMentorMode) return
  if (localStorage.getItem('mentor-mode')) {
    checkboxMentorMode.checked = true
    jsMentorModeClass.classList.add('is-mentor-mode')
  } else {
    checkboxMentorMode.checked = false
    jsMentorModeClass.classList.remove('is-mentor-mode')
  }
  checkboxMentorMode.addEventListener('click', () => {
    if (checkboxMentorMode.checked) {
      localStorage.setItem('mentor-mode', 'on')
      jsMentorModeClass.classList.add('is-mentor-mode')
    } else {
      localStorage.removeItem('mentor-mode')
      jsMentorModeClass.classList.remove('is-mentor-mode')
    }
  })
})
