document.addEventListener('DOMContentLoaded', () => {
  const editors = document.getElementsByName('user[editor]')
  const othersRadio = document.getElementById('others')
  editors.forEach((editor) => {
    editor.addEventListener('change', () => {
      const othersForm = document.getElementById('others_form')
      othersForm.classList.toggle('is-hidden', !othersRadio.checked)
    })
  })

  const form = document.getElementById('payment-form')
  if (form) {
    form.addEventListener('submit', handleFormSubmit)
  }

  function handleFormSubmit() {
    const othersInput = document.getElementById('others_input')
    if (othersRadio.checked) {
      const othersValue = othersInput.value
      const hiddenInput = document.createElement('input')
      Object.assign(hiddenInput, {
        type: 'hidden',
        name: 'user[editor]',
        value: othersValue
      })
      form.appendChild(hiddenInput)
    }
  }
})
