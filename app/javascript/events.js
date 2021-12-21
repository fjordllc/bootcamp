import Vue from 'vue'
import Events from './events.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-events'
  const events = document.querySelector(selector)
  if (events) {
    new Vue({
      render: (h) => h(Events)
    }).$mount(selector)
  }

  document
    .getElementById('event_start_at')
    .addEventListener('blur', (event) => {
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
