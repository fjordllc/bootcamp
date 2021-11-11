import Vue from 'vue'
import ReportTemplate from './report_template.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-report-template'
  const reportTemplate = document.querySelector(selector)
  if (reportTemplate) {
    const registeredTemplate = reportTemplate.getAttribute(
      'template-description'
    )
    const templateId = reportTemplate.getAttribute('template-id')
    new Vue({
      render: (h) =>
        h(ReportTemplate, {
          props: {
            registeredTemplateProp: registeredTemplate,
            templateIdProp: templateId
          }
        })
    }).$mount(selector)
  }
})
