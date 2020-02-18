document.addEventListener('DOMContentLoaded', () => {
  const elements = document.getElementsByClassName('js-date-input-toggler')
  for (let element of elements) {
    const checkbox = element.querySelector('input.js-date-input-toggler-checkbox')
    const dateInput = element.querySelector('input.js-date-input-toggler-date')
    const dateInputArea = element.querySelector('.js-date-input-toggler-date-area')

    if (dateInput.value === '') {
      dateInputArea.style.display = 'none'
    } else {
      checkbox.checked = true
    }
    checkbox.addEventListener('change', () => {
      if (checkbox.checked === true) {
        dateInputArea.style.display = 'flex'
      } else {
        dateInput.value = ''
        dateInputArea.style.display = 'none'
      }
    })
  }
})
