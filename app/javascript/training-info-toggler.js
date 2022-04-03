document.addEventListener('DOMContentLoaded', () => {
  const elements = document.getElementsByClassName('form')
  for (const element of elements) {
    const checkbox = element.querySelector(
      'input.training-info-toggler-checkbox'
    )
    const dateInput = element.querySelector('input.training-info-toggler-date')
    const trainingInfoArea = element.querySelector('div.training-info-toggler')

    if (checkbox.checked === true) {
      trainingInfoArea.style.display = 'block'
    } else {
      dateInput.value = ''
      trainingInfoArea.style.display = 'none'
    }
    checkbox.addEventListener('change', () => {
      if (checkbox.checked === true) {
        trainingInfoArea.style.display = 'block'
      } else {
        dateInput.value = ''
        trainingInfoArea.style.display = 'none'
      }
    })
  }
})
