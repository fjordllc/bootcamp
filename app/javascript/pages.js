import Vue from 'vue'
import Pages from './pages.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-pages'
  const pages = document.querySelector(selector)
  if (pages) {
    const selectedTag = pages.getAttribute('data-selected-tag')
    new Vue({
      render: (h) =>
        h(Pages, {
          props: { selectedTag: selectedTag }
        })
    }).$mount(selector)
  }
})
