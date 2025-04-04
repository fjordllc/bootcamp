// import Vue from 'vue'
// import LearningStatus from 'learning-status.vue'

// document.addEventListener('DOMContentLoaded', () => {
//   const learningStatuses = document.querySelectorAll('.js-learning-status')
//   if (learningStatuses) {
//     for (let i = 0; i < learningStatuses.length; i++) {
//       const learningStatus = learningStatuses[i]

//       const practiceId = learningStatus.getAttribute('data-practice-id')
//       const status = learningStatus.getAttribute('data-status')
//       const submission = learningStatus.getAttribute('data-submission')
//       new Vue({
//         render: (h) =>
//           h(LearningStatus, {
//             props: {
//               practiceId: practiceId,
//               status: status,
//               submission: submission
//             }
//           })
//       }).$mount('.js-learning-status')
//     }
//   }
// })

import 'whatwg-fetch'
import CSRF from 'csrf'

document.addEventListener('DOMContentLoaded', () => {
  const buttons = document.querySelectorAll('.practice-status-buttons__button')

  const pushStatus = (name, button) => {
    const params = new FormData()
    params.append('status', name)
    const practice = document.querySelector('#practice')

    fetch(`/api/practices/${practice.dataset.id}/learning.json`, {
      method: 'PATCH',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: params
    }).then((response) => {
      if (response.ok) {
        console.log('成功してます')
      } else {
        response.json().then((data) => {
          alert(data.error)
        })
      }
    })
  }

  buttons.forEach((button) => {
    button.addEventListener('click', (event) => {
      const clickedButton = event.target
      if (clickedButton.classList.contains('js-not-complete')) {
        console.log('未着手ボタンが押されました')
        pushStatus('unstarted', clickedButton)
      } else if (clickedButton.classList.contains('js-started')) {
        console.log('着手ボタンが押されました')
        pushStatus('started', clickedButton)
      } else if (clickedButton.classList.contains('js-submitted')) {
        console.log('提出済みボタンが押されました')
        pushStatus('submitted', clickedButton)
      } else if (clickedButton.classList.contains('js-complete')) {
        console.log('修了ボタンが押されました')
        pushStatus('complete', clickedButton)
      }
    })
  })
})
