document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const checkboxMentorMode = document.querySelector('.js-mentor-mode__trigger')
  const jsMentorModeClass = document.body
  if (!checkboxMentorMode) return
  if (localStorage.getItem('mentor-mode')) {
    checkboxMentorMode.checked = false
    jsMentorModeClass.classList.remove('is-mentor-mode')
  } else {
    checkboxMentorMode.checked = true
    jsMentorModeClass.classList.add('is-mentor-mode')
  }
  checkboxMentorMode.addEventListener('click', () => {
    if (checkboxMentorMode.checked) {
      localStorage.removeItem('mentor-mode')
      jsMentorModeClass.classList.add('is-mentor-mode')
    } else {
      localStorage.setItem('mentor-mode', 'off')
      jsMentorModeClass.classList.remove('is-mentor-mode')
    }
  })
})
