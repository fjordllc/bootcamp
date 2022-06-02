import Vue from 'vue'
import Products from 'products.vue'
import store from './check-store.js'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-products'
  const products = document.querySelector(selector)
  if (products) {
    const title = products.getAttribute('data-title')
    const selectedTab = products.getAttribute('data-selected-tab')
    const isMentor = products.getAttribute('data-mentor-login')
    const currentUserId = products.getAttribute('data-current-user-id')
    const checkerId = products.getAttribute('data-checker-id')
    new Vue({
      store,
      render: (h) =>
        h(Products, {
          props: {
            title: title,
            selectedTab: selectedTab,
            isMentor: isMentor === 'true',
            currentUserId: currentUserId,
            checkerId: checkerId
          }
        })
    }).$mount(selector)
  }
})
