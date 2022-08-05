import Vue from 'vue'
import Companies from 'companies.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-companies'
  const companies = document.querySelector(selector)
  if (companies) {
    const target = companies.getAttribute('data-target')
    new Vue({
      render: (h) =>
        h(Companies, {
          props: {
            target: target
          }
        })
    }).$mount(selector)
  }
})
