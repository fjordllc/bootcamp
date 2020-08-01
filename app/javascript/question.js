import Vue from 'vue'
import Question from './question.vue'

document.addEventListener('DOMContentLoaded', () => {
  const questionElement = document.getElementById('js-question')
  if (questionElement) {
    const currentUserId = questionElement.getAttribute('data-current-user-id')
    const questionUserId = questionElement.getAttribute('data-question-user-id')
    const questionId = questionElement.getAttribute('data-question-id')
    var adminLogin = questionElement.getAttribute('data-admin-login')
    adminLogin = adminLogin === 'true'
    var present = questionElement.getAttribute('data-present')
    present = present === 'true'

    new Vue({
      render: (h) =>
        h(Question, {
          props: {
            currentUserId: currentUserId,
            questionUserId: questionUserId,
            questionId: questionId,
            adminLogin: adminLogin,
            present: present
          }
        })
    }).$mount('#js-question')
  }
})
