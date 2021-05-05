import Vue from 'vue'
import Searchables from './searchables.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-searchables'
  const searchables = document.querySelector(selector)
  if (searchables) {
    new Vue({
      render: h => h(Searchables)
    }).$mount(selector)
  }
})
