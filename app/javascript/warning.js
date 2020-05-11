document.addEventListener('DOMContentLoaded', () => {
  const warningForms = document.querySelectorAll('.js-warning-form')
  if (warningForms.length <= 0) { return null }

  let submitting = false
  const commentForm = document.querySelector('#js-new-comment')
  const onUnload = () => {
    window.addEventListener('beforeunload', e => {
      if (!submitting && !commentForm) {
        e.preventDefault()
        e.returnValue = 'このページを離れると、入力したデータが削除されます。本当に移動しますか？'
      }
    })
  }
  for (let warningForm of warningForms) {
    warningForm.addEventListener('keyup', onUnload, false)
    warningForm.addEventListener('change', onUnload, false)
  }
  window.addEventListener('submit', () => {
    window.removeEventListener('beforeunload', onUnload, false)
    submitting = true
  })
})
