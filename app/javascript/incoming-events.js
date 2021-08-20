document.addEventListener('DOMContentLoaded', () => {
  const selector = '.incoming-events .event'
  const events = document.querySelectorAll(selector)
  if (!events) return false

  events.forEach((event) => {
    const eventId = event.getAttribute('data-event-id')
    const button = event.querySelector('.js-close-event')

    button.addEventListener('click', () => {
      document.querySelector(
        '#event.thread-list-item.incoming-events'
      ).remove()

      if (
        document.cookie
          .split('; ')
          .find((row) => row.startsWith('confirmed_event_ids')) === undefined
      ) {
        document.cookie =
          'confirmed_event_ids=' +
          JSON.stringify([eventId]) +
          ';max-age=2592000;' // 有効期限30日=259200秒
      } else {
        const originalEventIds = document.cookie
          .split('; ')
          .find((row) => row.startsWith('confirmed_event_ids'))
        const unnecessaryCharacters = 20
        const updatedEventIds = originalEventIds.substr(unnecessaryCharacters) // Keyである"confirmed_event_ids="の20文字を除きidであるvalue値のみを取得
        const savedEventIds = JSON.parse(updatedEventIds)
        savedEventIds.push(eventId)
        document.cookie =
          'confirmed_event_ids=' +
          JSON.stringify(savedEventIds) +
          ';max-age=2592000;' // 有効期限30日=259200秒
      }

      const eventCount = document.querySelectorAll(
        selector + ' .js-close-event'
      ).length
      if (eventCount < 1) {
        document.querySelector(
          '#events_on_dashboard.confirmed_event'
        ).remove()
      }
    })
  })
})
