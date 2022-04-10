document.addEventListener('DOMContentLoaded', () => {
  const checkbox = document.querySelector(
    'input.training-info-toggler-checkbox'
  )
  const dateInput = document.querySelector('input.training-info-toggler-date')
  const trainingInfoBlock = document.querySelector('div.training-info-block')

  if (checkbox) {
    if (checkbox.checked === false) {
      trainingInfoBlock.style.display = 'none'
    }

    checkbox.addEventListener('change', () => {
      if (checkbox.checked === true) {
        trainingInfoBlock.style.display = 'block'
      } else {
        dateInput.value = ''
        trainingInfoBlock.style.display = 'none'
      }
    })
  }
})
