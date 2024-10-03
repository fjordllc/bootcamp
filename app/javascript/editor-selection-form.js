document.addEventListener('DOMContentLoaded', () => {
  if (!document.querySelector('.is-current_user-edit')) {
    return null
  }

  const editors = document.getElementsByName('user[editor]')
  const otherEditor = document.getElementById('other_editor')
  editors.forEach((editor) => {
    editor.addEventListener('change', () => {
      const otherForm = document.getElementById('other_form')
      otherForm.classList.toggle('is-hidden', !otherEditor.checked)
    })
  })

  const form = document.getElementById('payment-form')
  if (form) {
    form.addEventListener('submit', handleFormSubmit)
  }

  function handleFormSubmit() {
    const otherInput = document.getElementById('other_input')
    if (otherEditor.checked) {
      const otherValue = otherInput.value
      const hiddenInput = document.createElement('input')
      Object.assign(hiddenInput, {
        type: 'hidden',
        name: 'user[other_editor]',
        value: otherValue
      })
      form.appendChild(hiddenInput)
    }
  }
})
