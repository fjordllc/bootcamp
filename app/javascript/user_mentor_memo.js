import Vue from 'vue'
import UserMentorMemo from './user_mentor_memo.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-user-mentor-memo'
  const userMentorMemo = document.querySelector(selector)
  if (userMentorMemo) {
    const userId = userMentorMemo.getAttribute('data-user-id')
    new Vue({
      render: h => h(UserMentorMemo, {
        props: {
          userId: userId
        }
      })
    }).$mount(selector)
  }
})
