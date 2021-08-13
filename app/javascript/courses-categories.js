import Vue from 'vue'
import CoursesCategories from './courses-categories.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-courses-categories'
  const categories = document.querySelector(selector)
  if (categories) {
    const allCategories = categories.getAttribute('data-categories')
    new Vue({
      render: (h) =>
        h(CoursesCategories, {
          props: {
            allCategories: allCategories
          }
        })
    }).$mount(selector)
  }
})
