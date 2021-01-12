document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('input').forEach((e) => {
    const jsUsersVisibilityTriggerClass = e.classList.contains('js-users-visibility__trigger')
    if (e.checked && !jsUsersVisibilityTriggerClass) {
      e.parentNode.classList.add('is-checked')
    }
  })
  document.querySelectorAll('input').forEach((value) => {
    value.addEventListener('click', (c) => {
      var chk, t
      t = c.target.type
      chk = value.checked
      if (t === 'checkbox') {
        const jsUsersVisibilityTriggerClass = value.classList.contains('js-users-visibility__trigger')
        if (!jsUsersVisibilityTriggerClass) {
          if (chk) {
            value.parentNode.classList.add('is-checked')
          } else {
            value.parentNode.classList.remove('is-checked')
          }
        }
      } else if (t === 'radio') {
        if (chk) {
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
