function initializeDateInputToggler() {
  const elements = document.getElementsByClassName('js-date-input-toggler')
  for (const element of elements) {
    const checkbox = element.querySelector(
      'input.js-date-input-toggler-checkbox'
    )
    const dateInput = element.querySelector('input.js-date-input-toggler-date')
    const dateInputArea = element.querySelector(
      '.js-date-input-toggler-date-area'
    )

    if (!checkbox || !dateInput || !dateInputArea) continue

    // Initialize visibility based on checkbox state
    if (checkbox.checked) {
      dateInputArea.style.display = 'flex'
      dateInputArea.classList.remove('is-hidden')
    } else {
      dateInputArea.style.display = 'none'
      dateInputArea.classList.add('is-hidden')
    }

    // Define the event handler function
    const handleCheckboxChange = function () {
      if (checkbox.checked === true) {
        dateInputArea.style.display = 'flex'
        dateInputArea.classList.remove('is-hidden')
        dateInput.focus()
      } else {
        dateInput.value = ''
        dateInputArea.style.display = 'none'
        dateInputArea.classList.add('is-hidden')
      }
    }

    // Remove existing event listeners to avoid duplicates
    checkbox.removeEventListener('change', handleCheckboxChange)
    checkbox.addEventListener('change', handleCheckboxChange)
  }
}

// Initialize on DOMContentLoaded
document.addEventListener('DOMContentLoaded', initializeDateInputToggler)

// Also initialize on Turbo events for Rails 7
document.addEventListener('turbo:load', initializeDateInputToggler)
document.addEventListener('turbo:frame-load', initializeDateInputToggler)

// For older Turbolinks compatibility
document.addEventListener('turbolinks:load', initializeDateInputToggler)