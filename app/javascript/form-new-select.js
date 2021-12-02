import Vue from 'vue'
import FormNewSelect from './form-new-select.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = "#js-select2"
  const practiceSelect = document.querySelector(selector)
  new Vue({
    render: (h) =>
      h(FormNewSelect, {
        props: {
          title: practiceSelect
        }
      })
  }).$mount(selector)
})
