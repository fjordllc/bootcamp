import Vue from 'vue'
import Question from './question-page.vue'

document.addEventListener('DOMContentLoaded', () => {
  const questionElement = document.getElementById('js-question')
  if (questionElement) {
    const currentUserId = questionElement.getAttribute('data-current-user-id')
    const questionId = questionElement.getAttribute('data-question-id')

    new Vue({
      render: (h) =>
        h(Question, {
          props: {
            currentUserId: currentUserId,
            questionId: questionId
          }
        })
    }).$mount('#js-question')
  }
})
