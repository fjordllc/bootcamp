import Vue from 'vue'
import Reports from './reports.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-reports'
  const reports = document.querySelector(selector)
  if (reports) {
    new Vue({
      render: (h) => h(Reports)
    }).$mount(selector)
  }
})
