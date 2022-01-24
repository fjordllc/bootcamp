import Vue from 'vue'
import Talks from './talks.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-talks'
  const talks = document.querySelector(selector)
  if (talks) {
    new Vue({
      render: (h) => h(Talks)
    }).$mount(selector)
  }
})
