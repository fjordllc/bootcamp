import Vue from 'vue'
import UsersAnswers from './users-answers.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-users-answers'
  const usersAnswers = document.querySelector(selector)
  if (usersAnswers) {
    const userId = usersAnswers.getAttribute('data-user-id')
    new Vue({
      render: (h) =>
        h(UsersAnswers, {
          props: {
            usersPath: `users/${userId}/`
          }
        })
    }).$mount(selector)
  }
})
