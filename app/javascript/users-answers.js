import Vue from 'vue'
import UsersAnswers from './users-answers.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-users-answers'
  const usersAnswers = document.querySelector(selector)
  if (usersAnswers) {
    const emptyMessage = usersAnswers.getAttribute('data-empty-message')
    const selectedTag = usersAnswers.getAttribute('data-selected-tag')
    const userId = usersAnswers.getAttribute('data-user-id')
    new Vue({
      render: (h) =>
        h(UsersAnswers, {
          props: {
            emptyMessage,
            selectedTag,
            usersPath: `users/${userId}/`
          }
        })
    }).$mount(selector)
  }
})
