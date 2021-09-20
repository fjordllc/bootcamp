import Vue from 'vue'
import PracticeSelect from './practice-select.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-practice-select'
  const practiceSelect = document.querySelector(selector)
  const matchedTitle = location.search.match(/&title=.+$/g)
  const title = matchedTitle
    ? decodeURI(matchedTitle).replace('&title=', '').replace(/\+/g, ' ')
    : ''
  if (practiceSelect) {
    new Vue({
      render: (h) =>
        h(PracticeSelect, {
          props: {
            title: title,
            solved: practiceSelect.dataset.solved ?? '',
            currentUserId: practiceSelect.dataset.currentUserId
          }
        })
    }).$mount(selector)
  }
})
