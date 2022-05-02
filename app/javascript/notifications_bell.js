import Vue from 'vue'
import NotificationsBell from 'notifications_bell.vue'

document.addEventListener('DOMContentLoaded', () => {
  const notificationsBell = document.querySelector('#js-notifications-bell')
  if (notificationsBell) {
    new Vue({
      render: (h) => h(NotificationsBell)
    }).$mount('#js-notifications-bell')
  }
})
