function initializeTrainingInfoToggler() {
  const checkbox = document.querySelector(
    'input.js-training-info-toggler-checkbox'
  )

  if (checkbox !== null) {
    const dateInput = document.querySelector('input.training-info-date')
    const trainingInfoBlock = document.querySelector('.js-training-info-block')

    if (!dateInput) return null
    if (!trainingInfoBlock) return null

    // Initial state - hide if unchecked
    if (checkbox.checked === false) {
      trainingInfoBlock.style.display = 'none'
    } else {
      trainingInfoBlock.style.display = 'block'
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
}

// Initialize on different events for Rails 7.2 compatibility
document.addEventListener('DOMContentLoaded', initializeTrainingInfoToggler)
document.addEventListener('turbo:load', initializeTrainingInfoToggler)
document.addEventListener('turbo:frame-load', initializeTrainingInfoToggler)
// For older Turbolinks compatibility
document.addEventListener('turbolinks:load', initializeTrainingInfoToggler)
