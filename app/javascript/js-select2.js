document.addEventListener('turbolinks:before-cache', () => {
  $('.js-select2').select2('destroy')
})

document.addEventListener('turbolinks:load', () => {
  $('.js-select2').select2({
    closeOnSelect: true
  })
})
