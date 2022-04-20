import Vue from 'vue'
import NiconicoCalendar from 'niconico_calendar'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-niconico_calendar'
  const niconicoCalendar = document.querySelector(selector)
  if (niconicoCalendar) {
    const userId = niconicoCalendar.getAttribute('data-user-id')

    new Vue({
      render: (h) =>
        h(NiconicoCalendar, {
          props: {
            userId: userId
          }
        })
    }).$mount(selector)
  }
})
