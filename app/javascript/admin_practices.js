import Vue from 'vue'
import AdminPractices from 'admin_practices.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-admin-practices'
  const adminPractices = document.querySelector(selector)
  if (adminPractices) {
    const allAdminPractices = adminPractices.getAttribute('data-admin-practices')
    new Vue({
      render: (h) =>
        h(AdminPractices, {
          props: {
            allAdminPractices: allAdminPractices
          }
        })
    }).$mount(selector)
  }
})
