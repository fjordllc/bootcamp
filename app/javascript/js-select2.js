document.addEventListener('DOMContentLoaded', () => {
  const select2Elements = document.querySelectorAll('.js-select2')
  select2Elements.forEach((element) => {
    window.$(element).select2({
      closeOnSelect: true
    })
  })
})
