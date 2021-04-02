document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const checkboxMentorMode = document.querySelector('.js-mentor-mode__trigger')
  const jsMentorModeClass = document.body
  if (!checkboxMentorMode) return
  if (localStorage.getItem('mentor-mode')) {
    checkboxMentorMode.checked = false
    if (jsMentorModeClass !== null) {
      jsMentorModeClass.classList.remove('is-mentor-mode')
    }
  } else {
    checkboxMentorMode.checked = true
    if (jsMentorModeClass !== null) {
      jsMentorModeClass.classList.add('is-mentor-mode')
    }
  }
  checkboxMentorMode.addEventListener('click', () => {
    if (checkboxMentorMode.checked) {
      localStorage.removeItem('mentor-mode')
      if (jsMentorModeClass !== null) {
        jsMentorModeClass.classList.add('is-mentor-mode')
      }
    } else {
      localStorage.setItem('mentor-mode', 'off')
      if (jsMentorModeClass !== null) {
        jsMentorModeClass.classList.remove('is-mentor-mode')
      }
    }
  })
})
