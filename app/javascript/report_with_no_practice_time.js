document.addEventListener('DOMContentLoaded', () => {
  const checkIfNoPracticeTime = document.querySelector('.js-no-practice-time')
  const formItemClass = document.querySelector('#js-learning-times')
  if (checkIfNoPracticeTime) {
    if (checkIfNoPracticeTime.checked) {
      formItemClass.classList.add('is-hidden')
    } else {
      formItemClass.classList.remove('is-hidden')
    }
    checkIfNoPracticeTime.addEventListener('click', () => {
      if (checkIfNoPracticeTime.checked) {
        formItemClass.classList.add('is-hidden')
      } else {
        formItemClass.classList.remove('is-hidden')
      }
    })
  }
})
