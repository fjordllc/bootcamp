import Vue from 'vue'
import RecentReports from './recent_reports.vue'
import store from './check-store.js'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-recent-reports'
  const recentReports = document.querySelector(selector)
  if (recentReports) {
    new Vue({
      store,
      render: h => h(RecentReports)
    }).$mount(selector)
  }
})
