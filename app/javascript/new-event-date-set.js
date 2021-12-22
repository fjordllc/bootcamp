document.addEventListener('DOMContentLoaded', () => {
  const eventStartAt = document.getElementById('event_start_at')
  if (!eventStartAt) {
    return
  }

  eventStartAt.addEventListener('blur', (event) => {
    const eventStartAtDate = event.target.value
    const idsToSubstituteDate = ['event_end_at', 'event_open_end_at']
    idsToSubstituteDate.forEach((idToSubstituteDate) => {
      substituteDate(
        eventStartAtDate,
        document.getElementById(idToSubstituteDate)
      )
    })
  })

  function substituteDate(date, destElement) {
    if (destElement.value === '') {
      destElement.value = date
    }
  }
})
