import Vue from 'vue'
import UserReports from './user-recent-reports.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-user-recent-reports'
  const reports = document.querySelector(selector)
  if (reports) {
    const reportId = reports.getAttribute('report-id')
    new Vue({
      render: (h) => h(UserReports,{
        props:{
          reportId: reportId
        }
      })
    }).$mount(selector)
  }
})
