document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('input').forEach((input) => {
    if (input.checked) {
      input.parentNode.classList.add('is-checked')
    }
  })
  document.querySelectorAll('input').forEach((value) => {
    value.addEventListener('click', (e) => {
      const type = e.target.type
      const check = value.checked
      if (type === 'checkbox') {
        if (check) {
          value.parentNode.classList.add('is-checked')
        } else {
          value.parentNode.classList.remove('is-checked')
        }
      } else if (type === 'radio') {
        if (check) {
          document.querySelectorAll('ul, input').forEach(function (value) {
            if (value.type === 'radio') {
              value.parentNode.classList.remove('is-checked')
            }
          })
          value.parentNode.classList.add('is-checked')
        }
      }
    })
  })
})
