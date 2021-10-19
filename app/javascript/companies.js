import Vue from 'vue'
import Companies from './companies.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-companies'
  const companies = document.querySelector(selector)
  if (companies) {
    new Vue({
      render: (h) => h(Companies)
    }).$mount(selector)
  }
})
