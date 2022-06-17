import Vue from 'vue'
import RegularEvents from 'regular-events.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-regular-events'
  const regularEvents = document.querySelector(selector)
  if (regularEvents) {
    new Vue({
      render: (h) => h(RegularEvents)
    }).$mount(selector)
  }
})
