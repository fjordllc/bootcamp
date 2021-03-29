document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const checkboxMentorMode = document.querySelector('.js-mentor-mode__trigger')
  const jsMentorModeClass = document.querySelector('.is-memo')
  if (checkboxMentorMode){
    if (localStorage.getItem('mentor-mode')) {
      checkboxMentorMode.checked = false
      jsMentorModeClass?.classList.add('is-only-mentor')
    }
    checkboxMentorMode.addEventListener('click', () => {
      if (checkboxMentorMode.checked) {
        localStorage.removeItem('mentor-mode')
        jsMentorModeClass?.classList.remove('is-only-mentor')
      } else {
        localStorage.setItem('mentor-mode', 'off')
        jsMentorModeClass?.classList.add('is-only-mentor')
      }
    })
  }
  })
