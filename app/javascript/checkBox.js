document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('input').forEach((e) => {
    if (e.checked === true) {
      e.parentNode.classList.add('is-checked')
    }
  })
  document.querySelectorAll('input').forEach((value) => {
    value.addEventListener('click', (c) => {
      var chk, t
      t = c.target.type
      chk = value.checked
      if (t === 'checkbox') {
        if (chk === true) {
          value.parentNode.classList.add('is-checked')
        } else {
          value.parentNode.classList.remove('is-checked')
        }
        return true
      } else if (t === 'radio') {
        if (chk === true) {
          document.querySelectorAll('ul, input').forEach(function (value) {
            if (value.type === 'radio') {
              value.parentNode.classList.remove('is-checked')
            }
          })
          value.parentNode.classList.add('is-checked')
        }
        return true
      }
    })
  })
})
