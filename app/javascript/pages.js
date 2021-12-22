import Vue from 'vue'
import Pages from './pages.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-pages'
  const pages = document.querySelector(selector)
  if (pages) {
    const title = pages.getAttribute('data-title')
    const currentUserId = pages.getAttribute('data-current-user-id')
    new Vue({
      render: (h) =>
        h(Pages, {
          props: { title: title, currentUserId: currentUserId }
        })
    }).$mount(selector)
  }
})
