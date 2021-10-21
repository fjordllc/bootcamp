import Vue from 'vue'
import ReportTemplate from './report_template.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-report-template'
  const reportTemplate = document.querySelector(selector)
  if (reportTemplate) {
    const template = reportTemplate.getAttribute('template')
    new Vue({
      render: (h) =>
        h(ReportTemplate, {
          props: {
            template: template
          }
        })
    }).$mount(selector)
  }
})
