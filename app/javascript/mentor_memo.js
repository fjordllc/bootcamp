import Vue from 'vue'
import MentorMemo from './mentor_memo.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-mentor-memo'
  const mentorMemo = document.querySelector(selector)
  if (mentorMemo) {
    const practiceId = mentorMemo.getAttribute('data-practice-id')
    new Vue({
      render: h =>
        h(MentorMemo, {
          props: {
            practiceId: practiceId
          }
        })
    }).$mount(selector)
  }
})
