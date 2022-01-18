import Vue from 'vue'
import AdminCompanies from './admin_companies.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-admin-companies'
  const adminCompanies = document.querySelector(selector)
  if (adminCompanies) {
    new Vue({
      render: (h) => h(AdminCompanies)
    }).$mount(selector)
  }
})
