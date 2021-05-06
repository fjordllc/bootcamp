import Vue from 'vue'
import Following from './following.vue'

document.addEventListener('DOMContentLoaded', () => {
  const followings = document.querySelectorAll('.js-following')
  if (followings) {
    for (let i = 0; i < followings.length; i++) {
      const following = followings[i]
      const isFollowing = following.getAttribute('data-is-following')
      const userId = following.getAttribute('data-user-id')

      new Vue({
        render: (h) =>
          h(Following, {
            props: {
              isFollowing: isFollowing === 'true',
              userId: Number(userId)
            }
          })
      }).$mount('.js-following')
    }
  }
})
