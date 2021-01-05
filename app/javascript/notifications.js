import Vue from 'vue'
import Notifications from './notifications.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-notifications'
  const notifications = document.querySelector(selector)
  if (notifications) {
    new Vue({
      render: h => h(Notifications)
    }).$mount(selector)
  }
})
