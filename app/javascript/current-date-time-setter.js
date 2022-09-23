import dayjs from 'dayjs'

document.addEventListener('DOMContentLoaded', () => {
  const currentDateTimeButton = document.getElementById(
    'js-current-date-time-input-button'
  )
  const dateTimeField = document.getElementById('date_time_input_field')
  function reflectDateTime() {
    const currentDateTime = dayjs().format('YYYY-MM-DD HH:mm')
    dateTimeField.value = currentDateTime
  }
  if (currentDateTimeButton) {
    currentDateTimeButton.addEventListener('click', reflectDateTime)
  }
})
