document.addEventListener('DOMContentLoaded', () => {
  $('.reference-books-form__add')
  .on('cocoon:after-insert', () => {
    $('.js-select2').select2({
      closeOnSelect: true
    })
  })
})
