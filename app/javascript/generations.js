import Vue from 'vue'
import Generations from 'generations.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-generations'
  const generations = document.querySelector(selector)
  if (generations) {
    new Vue({
      render: (h) => h(Generations)
    }).$mount(selector)
  }
})
