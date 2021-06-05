import Vue from 'vue'
import Bookmarks from './bookmarks.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-bookmarks'
  const bookmarks = document.querySelector(selector)
  if (bookmarks) {
    new Vue({
      render: (h) =>
        h(Bookmarks)
    }).$mount(selector)
  }
})
