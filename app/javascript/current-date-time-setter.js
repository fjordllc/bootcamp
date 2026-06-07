import { formatDateTimeLocal } from 'utilities/date'

document.addEventListener('DOMContentLoaded', () => {
  const currentDateTimeButton = document.getElementById(
    'js-current-date-time-input-button'
  )
  if (!currentDateTimeButton) return
  const dateTimeField = document.getElementById('date_time_input_field')
  function reflectDateTime() {
    dateTimeField.value = formatDateTimeLocal()
  }
  currentDateTimeButton.addEventListener('click', reflectDateTime)
})
