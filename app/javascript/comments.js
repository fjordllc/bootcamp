import Vue from 'vue'
import Comments from 'comments.vue'
import store from 'check-store.js'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-comments'
  const comments = document.querySelector(selector)
  if (comments) {
    const commentableId = comments.getAttribute('data-commentable-id')
    const commentableType = comments.getAttribute('data-commentable-type')
    const currentUserId = Number(comments.getAttribute('data-current-user-id'))
    const initialCompleted = comments.getAttribute('data-is-completed')
    const currentUser = window.currentUser
    new Vue({
      store,
      render: (h) =>
        h(Comments, {
          props: {
            commentableId: commentableId,
            commentableType: commentableType,
            currentUserId: currentUserId,
            currentUser: currentUser,
            initialActionCompleted: initialCompleted === 'true'
          }
        })
    }).$mount(selector)
  }
})
