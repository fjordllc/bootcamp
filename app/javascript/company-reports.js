import Vue from 'vue'
import Reports from './reports.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-company-reports'
  const reports = document.querySelector(selector)
  if (reports) {
    const companyId = reports.getAttribute('company-id')
    new Vue({
      render: (h) =>
        h(Reports, {
          props: {
            companyId: companyId
          }
        })
    }).$mount(selector)
  }
})
