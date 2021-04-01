document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const checkboxMentorMode = document.querySelector('.js-mentor-mode__trigger')
  const jsMentorModeClass = document.querySelector('.is-memo')
  if (!checkboxMentorMode) return
  if (localStorage.getItem('mentor-mode')) {
    checkboxMentorMode.checked = false
    if (jsMentorModeClass !== null) {
      jsMentorModeClass.classList.add('is-only-mentor')
    }
  }
  checkboxMentorMode.addEventListener('click', () => {
    if (checkboxMentorMode.checked) {
      localStorage.removeItem('mentor-mode')
      if (jsMentorModeClass !== null) {
        jsMentorModeClass.classList.remove('is-only-mentor')
      }
    } else {
      localStorage.setItem('mentor-mode', 'off')
      if (jsMentorModeClass !== null) {
        jsMentorModeClass.classList.add('is-only-mentor')
      }
    }
  })
})
