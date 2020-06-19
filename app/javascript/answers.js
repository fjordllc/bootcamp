import Vue from 'vue'
import Answers from './answers.vue'

document.addEventListener('DOMContentLoaded', () => {
  const answers = document.getElementById('js-answers')
  if (answers) {
    const questionId = answers.getAttribute('data-question-id')
    const currentUserId = answers.getAttribute('data-current-user-id')
    const questionUserId = answers.getAttribute('data-question-user-id')
    new Vue({
      render: h => h(Answers, { props: { questionId: questionId, currentUserId: currentUserId, questionUserId: questionUserId } })
    }).$mount('#js-answers')
  }
})
