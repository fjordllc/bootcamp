document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const jsUsersVisibilityClass = document.querySelector('.js-users-visibility')
  document.querySelectorAll('input').forEach((e) => {
    const jsUsersVisibilityTriggerClass = e.classList.contains('js-users-visibility__trigger')
    if (localStorage.getItem('hidden-users') && jsUsersVisibilityTriggerClass) {
      document.querySelector('.js-users-visibility').classList.add('is-hidden-users')
      e.checked = false
    }
  })
  document.querySelectorAll('input').forEach((value) => {
    value.addEventListener('click', (c) => {
      const t = c.target.type
      const chk = value.checked
      if (t === 'checkbox') {
        const jsUsersVisibilityTriggerClass = value.classList.contains('js-users-visibility__trigger')
        if (jsUsersVisibilityTriggerClass) {
          if (chk) {
            jsUsersVisibilityClass.classList.remove('is-hidden-users')
            localStorage.removeItem('hidden-users')
          } else {
            jsUsersVisibilityClass.classList.add('is-hidden-users')
            localStorage.setItem('hidden-users', 'on')
          }
        }
      }
    })
  })
})
