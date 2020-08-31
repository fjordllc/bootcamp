import Vue from 'vue'
import RecentReports from './recent_reports.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-recent-reports'
  const recentReports = document.querySelector(selector)
  if (recentReports) {
    new Vue({
      render: h => h(RecentReports)
    }).$mount(selector)
  }
})
