function setupWarning() {
  const warningForms = document.querySelectorAll('.js-warning-form')
  if (warningForms.length <= 0) {
    return null
  }

  let submitting = false
  const commentForm = document.querySelector('#js-new-comment')

  const beforeUnload = (e) => {
    if (!submitting && !commentForm) {
      e.preventDefault()
      e.returnValue =
        'このページを離れると、入力したデータが削除されます。本当に移動しますか？'
    }
  }

  const onUnload = (event) => {
    if (event.currentTarget.dataset.warningInitialized === 'true') return

    event.currentTarget.dataset.warningInitialized = 'true'
    window.addEventListener('beforeunload', beforeUnload)
  }

  for (const warningForm of warningForms) {
    warningForm.addEventListener('keyup', onUnload, false)
    warningForm.addEventListener('change', onUnload, false)
  }
  const onSubmit = () => {
    submitting = true
    window.removeEventListener('beforeunload', beforeUnload)
  }

  document.addEventListener('submit', onSubmit, true)
  document
    .querySelectorAll('input[type="submit"], button[type="submit"]')
    .forEach((button) => button.addEventListener('click', onSubmit))
}

document.addEventListener('turbo:load', setupWarning)
document.addEventListener('DOMContentLoaded', setupWarning)
setupWarning()
