import Vue from 'vue'
import ReportFormMultielect from './report_form_multiselect.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-report-form-multiselect'
  const practiceSelect = document.querySelector(selector)
  if (practiceSelect) {
    const practices = practiceSelect.getAttribute('data-practices')
    const editdata = practiceSelect.getAttribute('data-edit')
    new Vue({
      render: (h) =>
        h(ReportFormMultielect, {
          props: {
            practices: practices,
            editpractices: JSON.parse(editdata)
          }
        })
    }).$mount(selector)
  }
})