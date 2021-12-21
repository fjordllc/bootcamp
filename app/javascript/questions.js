import Vue from 'vue'
import Questions from './questions.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-questions'
  const questions = document.querySelector(selector)
  if (questions) {
    const emptyMessage = questions.getAttribute('data-empty-message')
    const selectedTag = questions.getAttribute('data-selected-tag')
    new Vue({
      render: (h) =>
        h(Questions, {
          props: {
            emptyMessage,
            selectedTag
          }
        })
    }).$mount(selector)
  }
})
