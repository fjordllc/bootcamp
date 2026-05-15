document.addEventListener('DOMContentLoaded', () => {
  const checkbox = document.querySelector('.js-hibernation-agreements-checkbox')
  const submit = document.querySelector('.js-hibernation-agreements-submit')

  if (!checkbox) return
  if (!submit) return

  checkbox.addEventListener('change', () => {
    if (checkbox.checked) {
      submit.classList.remove('is-disabled')
      submit.classList.add('is-danger')
    } else {
      submit.classList.add('is-disabled')
      submit.classList.remove('is-danger')
    }
  })
})
