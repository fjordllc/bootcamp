import Vue from 'vue'
import UserMentorMemo from './user_mentor_memo.vue'

document.addEventListener('DOMContentLoaded', () => {
  const userMentorMemo = document.querySelector('#js-user-mentor-memo')
  if (userMentorMemo) {
    const userId = userMentorMemo.getAttribute('data-user-id')
    new Vue({
      render: h => h(UserMentorMemo, {
        props: {
          userId: userId
        }
      })
    }).$mount('#js-user-mentor-memo')
  }
})
