document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const checkIfNoPracticeTime = document.querySelector('.js-no-practice-time')
  const formItemClass = document.querySelector('.form-item#tasks')
  if (!checkIfNoPracticeTime) return
  if (checkIfNoPracticeTime) {
    if (localStorage.getItem('inactive')) {
      checkIfNoPracticeTime.checked = true
      formItemClass.classList.add('is-inactive')
    } else {
      checkIfNoPracticeTime.checked = false
      formItemClass.classList.remove('is-inactive')
    }
    checkIfNoPracticeTime.addEventListener('click', () => {
      if (checkIfNoPracticeTime.checked) {
        localStorage.setItem('inactive', 'on')
        formItemClass.classList.add('is-inactive')
      } else {
        localStorage.removeItem('inactive')
        formItemClass.classList.remove('is-inactive')
      }
    })
  }
})
