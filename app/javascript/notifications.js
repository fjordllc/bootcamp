import Vue from 'vue'
import Notifications from './notifications.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-notifications'
  const notifications = document.querySelector(selector)
  if (notifications) {
    const mentorLogin = notifications.getAttribute('data-mentor-login')
    new Vue({
      render: h => h(Notifications, {
        props: {
          // 文字列を真偽値に変換して渡す
          mentorLogin: mentorLogin === 'true'
        }
      })
    }).$mount(selector)
  }
})
