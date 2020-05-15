import Vue from 'vue'
import Answers from './answers.vue'

document.addEventListener('DOMContentLoaded', () => {
  const answers = document.getElementById('js-answers')
  if (answers) {
    const questionId = answers.getAttribute('data-question-id')
    // const type = answers.getAttribute('data-type')
    const currentUserId = answers.getAttribute('data-current-user-id')
    new Vue({
      // render: h => h(Answers, { props: { questionId: questionId, type: type, currentUserId: currentUserId } })
      render: h => h(Answers, { props: { questionId: questionId, currentUserId: currentUserId } })
    }).$mount('#js-answers')
  }
})
