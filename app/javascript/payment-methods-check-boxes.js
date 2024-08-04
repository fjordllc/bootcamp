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
