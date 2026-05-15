import { debounce } from './debounce.js'

window.addEventListener('DOMContentLoaded', function () {
  const textarea = document.getElementById('js-micro-report-textarea')
  const microReports = document.getElementById('js-micro-reports')
  const form = document.getElementById('js-micro-report-form')
  const submitButton = document.getElementById('js-shortcut-submit')
  let prevHeight = 0

  const adjustPadding = () => {
    const height = form.scrollHeight
    if (height !== prevHeight) {
      microReports.style.paddingBottom = height + 'px'
      prevHeight = height
    }
  }

  if (form) {
    // Event listener for textarea input
    submitButton.disabled = true
    textarea.addEventListener('input', function () {
      debounce(adjustPadding, 100)()
      submitButton.disabled = textarea.value.trim() === ''
    })
  }
})
