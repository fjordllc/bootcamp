document.addEventListener('DOMContentLoaded', () => {
  const checkBox = document.querySelector('.js-no-practice-time')
  const times = document.querySelector('#js-learning-times')
  if (!checkBox || !times) {
    return null
  }

  if (document.querySelector('#report_no_learn').checked) {
    if (!times.classList.contains('is-hidden')) {
      times.classList.add('is-hidden')
    }
  }

  checkBox.addEventListener('change', (event) => {
    times.classList.toggle('is-hidden')
    if (event.target.checked) {
      times.querySelectorAll('.nested-fields').forEach((field) => field.remove())
    }
  })
})
