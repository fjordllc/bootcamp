document.addEventListener('DOMContentLoaded', () => {
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
  document.querySelector('.js-warning-form').addEventListener('keyup', onUnload, false)
  document.querySelector('.js-warning-form').addEventListener('change', onUnload, false)
  window.addEventListener('submit', () => {
    window.removeEventListener('beforeunload', onUnload, false)
    submitting = true
  })
})
