import Vue from 'vue'
import FormNewSelect from './form-new-select.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = "#js-form-new-select"
  const practiceSelect = document.querySelector(selector)
  if (practiceSelect) {
    const practices = practiceSelect.getAttribute("data-practices")
    let editdata = practiceSelect.getAttribute("data-edit")
    console.log(editdata)
    new Vue({
      render: (h) =>
        h(FormNewSelect, {
          props: {
            practices: practices,
            editpractices: JSON.parse(editdata)
          }
        })
    }).$mount(selector)
  }
})
