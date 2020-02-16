document.addEventListener('DOMContentLoaded', () => {
  const elements = document.getElementsByClassName('js-date-input-toggler')
  for (let element of elements) {
    const checkbox = element.querySelector('input[type="checkbox"]')
    const dateInput = element.querySelector('input[type="date"]')

    if (dateInput.value === '') {
      dateInput.style.display = 'none'
    } else {
      checkbox.checked = true
    }

    checkbox.addEventListener('change', () => {
      if (checkbox.checked === true) {
        dateInput.style.display = 'block'
      } else {
        dateInput.value = ''
        dateInput.style.display = 'none'
      }
    })
  }
})
