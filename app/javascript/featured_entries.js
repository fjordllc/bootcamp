import Vue from 'vue'
import FeaturedEntries from './featured_entries.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-featured-entries'
  const featuredEntries = document.querySelector(selector)
  if (featuredEntries) {
    const title = featuredEntries.getAttribute('data-title')
    const currentUserId = featuredEntries.getAttribute('data-current-user-id')
    new Vue({
      render: (h) =>
        h(FeaturedEntries, {
          props: { title: title, currentUserId: currentUserId }
        })
    }).$mount(selector)
  }
})
