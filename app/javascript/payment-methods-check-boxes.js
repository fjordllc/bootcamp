function keepCheckBoxChecked(checkBoxes) {
  checkBoxes.forEach((checkBox) => {
    if (checkBox) {
      checkBox.addEventListener('click', () => {
        if (!checkBox.checked) {
          checkBox.checked = true
        }
      })
    }
  })
}

document.addEventListener('DOMContentLoaded', () => {
  const invoiceCheckBox = document.querySelector('.checked-invoice-box')
  const creditCardCheckBox = document.querySelector('.checked-credit-card-box')
  const checkBoxes = [invoiceCheckBox, creditCardCheckBox]
  keepCheckBoxChecked(checkBoxes)
})

document.addEventListener('DOMContentLoaded', () => {
  const selectableInvoiceCheckBox = document.querySelector(
    '.selectable-invoice-box'
  )
  const selectableCreditCardCheckBox = document.querySelector(
    '.selectable-credit-card-box'
  )
  const checkBoxes = [selectableInvoiceCheckBox, selectableCreditCardCheckBox]
  if (checkBoxes.includes(null)) {
    return
  }
  const cardForm = document.getElementById('card')
  checkBoxes.forEach((checkBox) => {
    checkBox.addEventListener('click', (event) => {
      if (
        event.currentTarget === selectableCreditCardCheckBox &&
        event.currentTarget.checked
      ) {
        cardForm.classList.remove('hidden')
        selectableInvoiceCheckBox.checked = false
      } else if (
        event.currentTarget === selectableCreditCardCheckBox &&
        !event.currentTarget.checked
      ) {
        cardForm.classList.add('hidden')
      } else if (
        event.currentTarget === selectableInvoiceCheckBox &&
        event.currentTarget.checked
      ) {
        cardForm.classList.add('hidden')
        selectableCreditCardCheckBox.checked = false
      }
    })
  })
})
