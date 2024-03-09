document.addEventListener('DOMContentLoaded', () => {
  const checkboxes = Array.from(
    document.querySelectorAll('.js-agreements-checkbox')
  )
  const submit = document.querySelector('.js-agreements-submit')

  const updateSubmitButtonStateFromCheckbox = () => {
    const isSubmit = checkboxes.every((element) => element.checked)
    if (isSubmit) {
      submit.classList.remove('is-disabled')
    } else {
      submit.classList.add('is-disabled')
    }
  }

  if (checkboxes.length) {
    checkboxes.forEach((element) => {
      element.addEventListener('click', updateSubmitButtonStateFromCheckbox)
    })

    updateSubmitButtonStateFromCheckbox()
  }
})
