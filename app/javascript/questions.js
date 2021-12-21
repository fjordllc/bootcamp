import Vue from 'vue'
import Questions from './questions.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-questions'
  const questions = document.querySelector(selector)
  if (questions) {
    const title = questions.getAttribute('data-title')
    new Vue({
      render: (h) =>
        h(Questions, {
          props: {
            title: title
          }
        })
    }).$mount(selector)
  }
})
