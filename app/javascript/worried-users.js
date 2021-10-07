import Vue from 'vue'
import WorriedUsers from './worried-users.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-worried-users'
  const worriedUsers = document.querySelector(selector)
  if (worriedUsers) {
    new Vue({
      render: (h) => h(WorriedUsers)
    }).$mount(selector)
  }
})
