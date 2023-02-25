document.addEventListener('DOMContentLoaded', () => {
  const selector = '.page-notices__item'
  const events = document.querySelectorAll(selector)
  if (!events) return false

  events.forEach((event) => {
    const eventId = event.getAttribute('data-event-id')
    const eventType = event.getAttribute('data-event-type')
    const button = event.querySelector('.js-close-event')
    const key = {
      Event: 'confirmed_event_ids=',
      RegularEvent: 'confirmed_regular_event_ids='
    }[eventType]

    button.addEventListener('click', () => {
      document
        .querySelector(
          `.page-notices__item[data-event-id="${eventId}"][data-event-type="${eventType}"]`
        )
        .remove()

      if (
        document.cookie.split('; ').find((row) => row.startsWith(key)) ===
        undefined
      ) {
        saveCookie(key, [eventId])
      } else {
        const latestCookie = document.cookie
          .split('; ')
          .find((row) => row.startsWith(key))
        const eventIds = updateEventIds(key, latestCookie, eventId)
        saveCookie(key, eventIds)
      }

      const eventCount = document.querySelectorAll(
        selector + ' .js-close-event'
      ).length
      if (eventCount < 1) {
        document.querySelector('#events_on_dashboard.confirmed_event').remove()
      }
    })
  })

  function saveCookie(key, eventIds) {
    const secondsFor30days = 2592000
    document.cookie =
      key + JSON.stringify(eventIds) + ';max-age=' + secondsFor30days
  }

  function updateEventIds(key, latestCookie, eventId) {
    const unnecessaryCharacters = key.length
    const latestEventIds = latestCookie.substr(unnecessaryCharacters)
    const updatedEventIds = JSON.parse(latestEventIds)
    updatedEventIds.push(eventId)
    return updatedEventIds
  }
})
