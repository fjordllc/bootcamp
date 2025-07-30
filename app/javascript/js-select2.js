function initializeSelect2() {
  $('.js-select2').select2({
    closeOnSelect: true
  })
}

// Initialize on different events for Rails 7.2 compatibility
document.addEventListener('DOMContentLoaded', initializeSelect2)
document.addEventListener('turbo:load', initializeSelect2)
document.addEventListener('turbo:frame-load', initializeSelect2)
// For older Turbolinks compatibility
document.addEventListener('turbolinks:load', initializeSelect2)
