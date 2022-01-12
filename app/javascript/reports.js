import Vue from 'vue'
import Reports from './reports.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-reports'
  const reports = document.querySelector(selector)
  if (reports) {
    const userId = reports.getAttribute('data-user-id')
    new Vue({
      render: (h) =>
        h(Reports, {
          props: { userId: userId }
        })
    }).$mount(selector)
  }
})
