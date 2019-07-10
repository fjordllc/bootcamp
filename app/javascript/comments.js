import Vue from 'vue'
import Comments from './comments.vue'

document.addEventListener('DOMContentLoaded', () => {
  const comments = document.getElementById('js-comments')
  if (comments) {
    const commentableId = comments.getAttribute('data-commentable-id')
    const commentableType = comments.getAttribute('data-commentable-type')
    const currentUserId = comments.getAttribute('data-current-user-id')
    new Vue({
      render: h => h(Comments, { props: { commentableId: commentableId, commentableType: commentableType, currentUserId: currentUserId } })
    }).$mount('#js-comments')
  }
})
