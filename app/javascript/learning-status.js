import Vue from 'vue'
import LearningStatus from './learning-status.vue'

document.addEventListener('DOMContentLoaded', () => {
  const learningStatuses = document.querySelectorAll('.js-learning-status')
  if (learningStatuses) {
    for (let i = 0; i < learningStatuses.length; i++) {
      let learningStatus = learningStatuses[i]

      const practiceId = learningStatus.getAttribute('data-practice-id')
      const status = learningStatus.getAttribute('data-status')
      const submission = learningStatus.getAttribute('data-submission')
      new Vue({
        render: h => h(LearningStatus, { props: { practiceId: practiceId, status: status, submission: submission } })
      }).$mount('.js-learning-status')
    }
  }
})
