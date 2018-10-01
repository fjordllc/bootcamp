import Vue from 'vue'
import Comments from './comments.vue'

document.addEventListener('DOMContentLoaded', () => {
  const commentsNode = document.getElementById('vue-comments')
  if (commentsNode) {
    const commentableId = commentsNode.getAttribute('data-commentable-id')
    new Vue({
      render: h => h(Comments, { props: { commentableId: commentableId } })
    }).$mount('#vue-comments')
  }
})
