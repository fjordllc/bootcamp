import Vue from 'vue'
import BookmarkButton from './bookmark-button.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-bookmark'
  const bookmark = document.querySelector(selector)
  if (bookmark) {
    const bookmarkbleId = Number(bookmark.getAttribute('data-bookmarkable-id'))
    const bookmarkableType = bookmark.getAttribute('data-bookmarkable-type')
    new Vue({
      render: (h) =>
        h(BookmarkButton, {
          props: {
            bookmarkableId: bookmarkbleId,
            bookmarkableType: bookmarkableType
          }
        })
    }).$mount(selector)
  }
})
