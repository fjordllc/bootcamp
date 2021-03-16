import Vue from 'vue'
import Announcements from './announcements.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-announcements'
  const announcements = document.querySelector(selector)
  if (announcements) {
    const title = announcements.getAttribute('data-title')
    const currentUserId = announcements.getAttribute('data-current-user-id')
    const isAdmin = announcements.getAttribute('data-admin-login')
    new Vue({
      render: h => h(Announcements, {
        props: {
          title: title,
          currentUserId: currentUserId,
          isAdmin: isAdmin
        }
      })
    }).$mount(selector)
  }
})
