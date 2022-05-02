import Vue from 'vue'
import Watches from 'watches.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-watches'
  const watches = document.querySelector(selector)
  if (watches) {
    new Vue({
      render: (h) => h(Watches)
    }).$mount(selector)
  }
})
