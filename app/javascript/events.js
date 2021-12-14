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

  const eventSets = [
    ['event_start_at', 'event_end_at'],
    ['event_open_start_at', 'event_open_end_at']
  ]
  eventSets.forEach((eventSet) => {
    document.getElementById(eventSet[0]).addEventListener('blur', (event) => {
      document.getElementById(eventSet[1]).value = event.target.value
    })
  })
})
