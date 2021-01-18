document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const checkboxProgress = document.querySelector('.js-users-visibility__trigger')
  const jsUsersVisibilityClass = document.querySelector('.js-users-visibility')
  if (checkboxProgress) {
    if (localStorage.getItem('hidden-users')) {
      jsUsersVisibilityClass.classList.add('is-hidden-users')
      checkboxProgress.checked = false
    }
    checkboxProgress.addEventListener('click', () => {
      if (checkboxProgress.checked) {
        jsUsersVisibilityClass.classList.remove('is-hidden-users')
        localStorage.removeItem('hidden-users')
      } else {
        jsUsersVisibilityClass.classList.add('is-hidden-users')
        localStorage.setItem('hidden-users', 'on')
      }
    })
  }
})
