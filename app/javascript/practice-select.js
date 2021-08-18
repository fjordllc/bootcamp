import Vue from 'vue'
import PracticeSelect from './practice-select.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-practice-select'
  const practiceSelect = document.querySelector(selector)
  if (practiceSelect) {
    new Vue({
      render: (h) =>
        h(PracticeSelect, {
          props: {
            solved: practiceSelect.dataset.solved ?? '',
            currentUserId: practiceSelect.dataset.currentUserId
          }
        })
    }).$mount(selector)
  }
})
