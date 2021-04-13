import Vue from 'vue'
import CorusesPractices from './courses-practices.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-courses-practices'
  const practices = document.querySelector(selector)
  if (practices) {
    const courseId = practices.getAttribute('course-id')
    const categories = practices.getAttribute('categories')
    const currentUserId = practices.getAttribute('data-current-user-id')
    const currentUser = window.currentUser
    new Vue({
      render: h => h(CorusesPractices,{
        props: {
          courseId: courseId,
          categories: categories,
          currentUserId: currentUserId,
          currentUser: currentUser
        }
      })
    }).$mount(selector)
  }
})
