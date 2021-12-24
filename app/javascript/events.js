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
})
