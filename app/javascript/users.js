import Vue from 'vue'
import Users from './users.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-users'
  const users = document.querySelector(selector)
  if (users) {
    new Vue({
      render: (h) => h(Users)
    }).$mount(selector)
  }
})
