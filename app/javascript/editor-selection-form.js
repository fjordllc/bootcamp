const othersEditorRadio = document.getElementById('others')
const othersEditorInput = document.getElementById('others_editor')
const toggleTextbox = document.getElementById('toggle-textbox')
const form = document.getElementById('payment-form')

function onChangeFunc() {
  if (othersEditorRadio) {
    toggleTextbox.style.display = othersEditorRadio.checked ? 'block' : 'none'
  }
}

document.addEventListener('DOMContentLoaded', function () {
  onChangeFunc()
  const radios = document.querySelectorAll('[name="user[editor]"]')
  radios.forEach(function (radio) {
    radio.addEventListener('change', onChangeFunc)
  })
})

if (form) {
  form.addEventListener('submit', handleFormSubmit)
}

function handleFormSubmit() {
  if (othersEditorRadio && othersEditorRadio.checked) {
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
