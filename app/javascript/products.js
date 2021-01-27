import Vue from 'vue'
import Products from './products.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-products'
  const products = document.querySelector(selector)
  if (products) {
    const title = products.getAttribute('data-title')
    const selectedTab = products.getAttribute('data-selected-tab')
    const mentorLogin = products.getAttribute('data-mentor-login')
    const currentUserId = products.getAttribute('data-current-user-id')
    new Vue({
      render: h => h(Products, {
        props: {
          title: title,
          selectedTab: selectedTab,
          mentorLogin: mentorLogin,
          currentUserId: currentUserId
        }
      })
    }).$mount(selector)
  }

  const allOpenButton = document.querySelector('#js-shortcut-unconfirmed-links-open')
  if (allOpenButton) {
    allOpenButton.addEventListener('click', () => {
      var links = document.querySelectorAll('.thread-list-item .js-unconfirmed-link')
      links.forEach(link => {
        window.open(link.href, '_target', 'noopener')
      })
    })
  }
})
