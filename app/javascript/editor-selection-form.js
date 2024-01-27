const othersEditorRadio = document.getElementById('others')
const othersEditorInput = document.getElementById('others_editor')
const toggleTextbox = document.getElementById('toggle-textbox')
const form = document.getElementById('payment-form')

function onChangeFunc() {
  if (othersEditorRadio.checked) {
    toggleTextbox.style.display = 'block'
  } else {
    toggleTextbox.style.display = 'none'
  }
}

document.addEventListener('DOMContentLoaded', function () {
  onChangeFunc()
  const radios = document.querySelectorAll('[name="user[editor]"]')
  radios.forEach(function (radio) {
    radio.addEventListener('change', onChangeFunc)
  })
})

form.addEventListener('submit', function () {
  if (othersEditorRadio.checked) {
    const othersEditorValue = othersEditorInput.value
    const hiddenInput = document.createElement('input')
    hiddenInput.setAttribute('type', 'hidden')
    hiddenInput.setAttribute('name', 'user[editor]')
    hiddenInput.setAttribute('value', othersEditorValue)

    form.appendChild(hiddenInput)
  }
})
