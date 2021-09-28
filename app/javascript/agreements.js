document.addEventListener('DOMContentLoaded', () => {
  const checkboxes = Array.from(
    document.querySelectorAll('.js-agreements-checkbox')
  )
  const submit = document.querySelector('.js-agreements-submit')

  checkboxes.forEach((element) => {
    element.addEventListener('click', () => {
      const isSubmit = checkboxes.every((element) => element.checked)

      if (isSubmit) {
        submit.classList.remove('is-disabled')
      } else {
        submit.classList.add('is-disabled')
      }
    })
  })
})
