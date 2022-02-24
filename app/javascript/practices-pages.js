import Vue from 'vue'
import Pages from './pages.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-practices-pages'
  const practicesPages = document.querySelector(selector)
  if (practicesPages) {
    const selectedTag = practicesPages.getAttribute('data-selected-tag')
    const practiceId = practicesPages.getAttribute('data-practice-id')
    new Vue({
      render: (h) =>
        h(Pages, {
          props: {
            selectedTag: selectedTag,
            nestedPath: `practices/${practiceId}/`
          }
        })
    }).$mount(selector)
  }
})
