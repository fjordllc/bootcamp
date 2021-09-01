document.addEventListener('DOMContentLoaded', () => {
  const selector = '.incoming-events'
  const events = document.querySelectorAll(selector)
  if (!events) return false

  events.forEach((event) => {
    const eventId = event.getAttribute('data-event-id')
    const button = event.querySelector('.js-close-event')

    button.addEventListener('click', () => {
      document.querySelector(`.thread-list-item.incoming-events[data-event-id="${eventId}"]`).remove()

      if (
        document.cookie
          .split('; ')
          .find((row) => row.startsWith('confirmed_event_ids')) === undefined
      ) {
        saveCookie([eventId])
      } else {
        const latestCookie = document.cookie
          .split('; ')
          .find((row) => row.startsWith('confirmed_event_ids'))
          saveCookie(updateEventIds(latestCookie, eventId))
      }

      const eventCount = document.querySelectorAll(
        selector + ' .js-close-event'
      ).length
      if (eventCount < 1) {
        document.querySelector('#events_on_dashboard.confirmed_event').remove()
      }
    })
  })

  function saveCookie(eventIds) {
    const secondsFor30days = 2592000
    document.cookie =
    'confirmed_event_ids=' +
    JSON.stringify(eventIds) +
    ';max-age=' +
    secondsFor30days
  }

  function updateEventIds(latestCookie, eventId) {
    const unnecessaryCharacters = 20
    const latestEventIds = latestCookie.substr(unnecessaryCharacters)
    const updatedEventIds = JSON.parse(latestEventIds)
    updatedEventIds.push(eventId)
    return updatedEventIds
  }
})
