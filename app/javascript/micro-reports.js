window.addEventListener('DOMContentLoaded', function () {
  const textarea = document.getElementById('js-micro-report-textarea')
  const microReports = document.getElementById('js-micro-reports')
  const form = document.getElementById('js-micro-report-form')
  const submitButton = document.getElementById('js-shortcut-submit')
  let prevHeight = 0

  submitButton.disabled = true

  const adjustPadding = () => {
    const height = form.scrollHeight
    if (height !== prevHeight) {
      microReports.style.paddingBottom = height + 'px'
      prevHeight = height
    }
  }

  if (form) {
    // Event listener for textarea input
    textarea.addEventListener('input', function () {
      debounce(adjustPadding, 100)()
      submitButton.disabled = textarea.value.trim() === ''
    })
  }

  // Debounce function to limit the rate of execution of a function
  function debounce(func, wait) {
    let timeout
    return function (...args) {
      clearTimeout(timeout)
      timeout = setTimeout(() => func.apply(this, args), wait)
    }
  }
})
