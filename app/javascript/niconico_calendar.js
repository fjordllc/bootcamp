import Vue from 'vue'
import NiconicoCalendar from './niconico_calendar'

document.addEventListener('DOMContentLoaded', () => {
  const niconicoCalendar = document.getElementById('js-niconico_calendar')
  if (niconicoCalendar) {
    const userId = niconicoCalendar.getAttribute('data-user-id')

    new Vue({
      render: (h) =>
        h(NiconicoCalendar, {
          props: {
            userId: userId
          }
        })
    }).$mount('#js-niconico_calendar')
  }
})
