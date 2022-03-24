import Vue from 'vue'
import Questions from './questions.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-users-questions'
  const questions = document.querySelector(selector)
  if (questions) {
    const emptyMessage = questions.getAttribute('data-empty-message')
    const selectedTag = questions.getAttribute('data-selected-tag')
    const userId = questions.getAttribute('data-user-id')
    new Vue({
      render: (h) =>
        h(Questions, {
          props: {
            emptyMessage,
            selectedTag,
            userId
          }
        })
    }).$mount(selector)
  }
})
