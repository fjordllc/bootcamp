document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  document.querySelectorAll('input').forEach((e) => {
    const categoriesItems = e.closest('.categories-items')
    if (localStorage.getItem('displayProgress') === 'off' && categoriesItems) {
      e.closest('.categories-items').classList.add('js-is-hidden-users')
      document.getElementById('displayProgress').checked = false
    } else if (e.checked === true && categoriesItems) {
      e.closest('.categories-items').classList.add('js-is-show-users')
    } else if (e.checked === true) {
      e.parentNode.classList.add('is-checked')
    }
  })
  document.querySelectorAll('input').forEach((value) => {
    value.addEventListener('click', (c) => {
      var chk, t
      t = c.target.type
      chk = value.checked
      if (t === 'checkbox') {
        const categoriesItems = value.closest('.categories-items')
        if (chk === true && categoriesItems) {
          value.closest('.categories-items').classList.remove('js-is-hidden-users')
          value.closest('.categories-items').classList.add('js-is-show-users')
          localStorage.removeItem('displayProgress')
        } else if (chk === true) {
          value.parentNode.classList.add('is-checked')
        } else if (chk === false && categoriesItems) {
          value.closest('.categories-items').classList.remove('js-is-show-users')
          value.closest('.categories-items').classList.add('js-is-hidden-users')
          localStorage.setItem('displayProgress', 'off')
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
