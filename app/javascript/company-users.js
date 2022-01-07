import Vue from 'vue'
import CompanyUsers from './company-users.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-company-users'
  const users = document.querySelector(selector)
  if (users) {
    const companyID = users.getAttribute('company-id')
    new Vue({
      render: (h) =>
        h(CompanyUsers, {
          props: {
            companyID: companyID
          }
        })
    }).$mount(selector)
  }
})
