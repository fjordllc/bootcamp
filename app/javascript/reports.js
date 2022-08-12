import Vue from 'vue'
import Reports from './components/reports'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-reports'
  const reports = document.querySelector(selector)
  if (reports) {
    const userId = reports.getAttribute('data-user-id')
    const limit = reports.getAttribute('data-limit')
    const companyId = reports.getAttribute('company-id')
    new Vue({
      render: (h) =>
        h(Reports, {
          props: { userId: userId, limit: limit, companyId: companyId }
        })
    }).$mount(selector)
  }
})
