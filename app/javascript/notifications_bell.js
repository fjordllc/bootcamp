import Vue from 'vue'
import NotificationsBell from './notifications_bell.vue'
import NotificationsBellMobile from './notifications_bell_mobile.vue'
import isMobile from 'ismobilejs'

document.addEventListener('DOMContentLoaded', () => {
  if (isMobile(window.navigator).any) {
    const notifications = document.querySelector('#js-notifications-bell')
    if (notifications) {
      notifications.style.display = 'none'
    }

    const notificationsBellMobile = document.querySelector('#js-notifications-bell-mobile')
    if (notificationsBellMobile) {
      new Vue({
        render: h => h(NotificationsBellMobile)
      }).$mount('#js-notifications-bell-mobile')
    }
  } else {
    const notificationsBellMobile = document.querySelector('#js-notifications-bell-mobile')
    if (notificationsBellMobile) {
      notificationsBellMobile.style.display = 'none'
    }

    const notificationsBell = document.querySelector('#js-notifications-bell')
    if (notificationsBell) {
      new Vue({
        render: h => h(NotificationsBell)
      }).$mount('#js-notifications-bell')
    }
  }
})
