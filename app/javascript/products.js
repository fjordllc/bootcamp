import Vue from 'vue'
import Products from 'products.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-products'
  const products = document.querySelector(selector)
  if (products) {
    const title = products.getAttribute('data-title')
    const selectedTab = products.getAttribute('data-selected-tab')
    const isMentor = products.getAttribute('data-mentor-login')
    const currentUserId = products.getAttribute('data-current-user-id')
    new Vue({
      render: (h) =>
        h(Products, {
          props: {
            title: title,
            selectedTab: selectedTab,
            isMentor: isMentor === 'true',
            currentUserId: currentUserId
          }
        })
    }).$mount(selector)
  }
})
