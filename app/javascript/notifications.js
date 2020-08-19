import Vue from 'vue'
import Notifications from './notifications.vue'
import NotificationsMobile from './notifications_mobile.vue'
import isMobile from 'ismobilejs'

document.addEventListener('DOMContentLoaded', () => {
  if (isMobile(window.navigator).any) {
    const notifications = document.querySelector('#js-notifications')
    if (notifications) {
      notifications.style.display = 'none'
    }

    const notificationsMobile = document.querySelector('#js-notifications-mobile')
    if (notificationsMobile) {
      new Vue({
        render: h => h(NotificationsMobile)
      }).$mount('#js-notifications-mobile')
    }
  } else {
    const notificationsMobile = document.querySelector('#js-notifications-mobile')
    if (notificationsMobile) {
      notificationsMobile.style.display = 'none'
    }

    const notifications = document.querySelector('#js-notifications')
    if (notifications) {
      new Vue({
        render: h => h(Notifications)
      }).$mount('#js-notifications')
    }
  }
})
