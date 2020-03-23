document.addEventListener('turbolinks:load', () => {
  const trigger = document.querySelectorAll('.js-show-handle__trigger')

  return trigger.forEach(value => {
    value.addEventListener('click', () => {
      if (value.classList.contains('is-active')) {
        value.closest('.js-show-handle').querySelectorAll('.js-show-handle__target').forEach((target) => {
          target.classList.remove('is-active')
        })
        value.classList.remove('is-active')
      } else {
        value.closest('.js-show-handle').querySelectorAll('.js-show-handle__target').forEach((target) => {
          target.classList.add('is-active')
        })
        value.classList.add('is-active')
      }
    })
  })
})
