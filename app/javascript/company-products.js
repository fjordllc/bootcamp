import Vue from 'vue'
import CompanyProducts from './company-products.vue'

document.addEventListener('DOMContentLoaded', () => {
    const selector = '#js-company-products'
    const products = document.querySelector(selector)
    if (products) {
        const title = products.getAttribute('data-title')
        const companyID = products.getAttribute('company-id')
        const isMentor = products.getAttribute('data-mentor-login')
        const currentUserId = products.getAttribute('data-current-user-id')
        new Vue({
            render: (h) =>
                h(CompanyProducts, {
                    props: {
                        title: title,
                        companyID: companyID,
                        isMentor: isMentor === 'true',
                        currentUserId: currentUserId
                    }
                })
        }).$mount(selector)
    }
})
