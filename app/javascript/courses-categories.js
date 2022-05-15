import Vue from 'vue'
import CoursesCategories from 'courses-categories.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-courses-categories'
  const coursesCategories = document.querySelector(selector)
  if (coursesCategories) {
    const allCoursesCategories = coursesCategories.getAttribute(
      'data-courses-categories'
    )


    new Vue({
      render: (h) =>
        h(CoursesCategories, {
          props: {
            allCoursesCategories: allCoursesCategories
          }
        })
    }).$mount(selector)


//    const App = createApp(CoursesCategories)
//    App.mount(selector);


  }
})
