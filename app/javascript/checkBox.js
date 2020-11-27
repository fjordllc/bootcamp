document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  document.querySelectorAll('input').forEach((e) => {
    const hasJsClass = e.hasClass('js-users-visibility__trigger')
    if (localStorage.getItem('hidden-users') === 'on' && hasJsClass) {
      e.closest('.js-users-visibility').classList.add('is-hidden-users')
      e.checked = false
    } else if (e.checked === true && !hasJsClass) {
      e.parentNode.classList.add('is-checked')
    }
  })
  document.querySelectorAll('input').forEach((value) => {
    value.addEventListener('click', (c) => {
      var chk, t
      t = c.target.type
      chk = value.checked
      if (t === 'checkbox') {
        const hasJsClass = value.hasClass('js-users-visibility__trigger')
        if (chk === true && hasJsClass) {
          value.closest('.js-users-visibility').classList.remove('is-hidden-users')
          localStorage.removeItem('hidden-users')
        } else if (chk === true) {
          value.parentNode.classList.add('is-checked')
        } else if (chk === false && hasJsClass) {
          value.closest('.js-users-visibility').classList.add('is-hidden-users')
          localStorage.setItem('hidden-users', 'on')
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
