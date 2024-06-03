import Vue from 'vue'
import Products from 'products.vue'
import store from './check-store.js'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-products'
  const products = document.querySelector(selector)
  if (products) {
    const title = products.getAttribute('data-title')
    const isMentor = products.getAttribute('data-mentor-login')
    const currentUserId = Number(products.getAttribute('data-current-user-id'))
    const productDeadlineDays = Number(products.getAttribute('data-product-deadline-days'))
    new Vue({
      store,
      render: (h) =>
        h(Products, {
          props: {
            title: title,
            isMentor: isMentor === 'true',
            currentUserId: currentUserId,
            productDeadlineDays: productDeadlineDays
          }
        })
    }).$mount(selector)
  }
})
