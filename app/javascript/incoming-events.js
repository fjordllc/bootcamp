document.addEventListener('DOMContentLoaded', () => {
  const selector = '.incoming-events .event'
  const events = document.querySelectorAll(selector)
  if (!events) return false

  events.forEach((event) => {
    const eventId = event.getAttribute('data-event-id')
    const button = event.querySelector('.js-close-event')

    button.addEventListener('click', () => {
      button.parentElement.innerHTML = ''

      // eventIdをcookieをセットする処理
      // .....

      const eventCount = document.querySelectorAll(selector + ' .js-close-event').length
      if (eventCount < 1) {
        document.querySelector('.incoming-events').parentElement.parentElement.innerHTML = ''
      }
    })
  })
})
