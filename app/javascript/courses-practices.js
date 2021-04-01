import Vue from 'vue'
import CorusesPractices from './courses-practices.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-courses-practices'
  const practices = document.querySelector(selector)
  if (practices) {
    new Vue({
      render: h => h(CorusesPractices)
    }).$mount(selector)
  }
})
