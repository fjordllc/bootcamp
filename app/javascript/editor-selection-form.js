document.addEventListener('DOMContentLoaded', () => {
  const editors = document.getElementsByName('user[editor]')
  const othersEditorRadio = document.getElementById('others')
  editors.forEach((editor) => {
    editor.addEventListener('change', () => {
      const othersEditorInput = document.getElementById('others_form')
      othersEditorInput.classList.toggle(
        'is-hidden',
        !othersEditorRadio.checked
      )
    })
  })

  const form = document.getElementById('payment-form')
  if (form) {
    form.addEventListener('submit', handleFormSubmit)
  }

  function handleFormSubmit() {
    const othersEditorInput = document.getElementById('others_editor')
    if (othersEditorRadio.checked) {
      const othersEditorValue = othersEditorInput.value
      const hiddenInput = document.createElement('input')
      Object.assign(hiddenInput, {
        type: 'hidden',
        name: 'user[editor]',
        value: othersEditorValue
      })
      form.appendChild(hiddenInput)
    }
  }
})
