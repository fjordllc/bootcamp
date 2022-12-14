import Vue from 'vue'
import Generations from 'generations.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-generations'
  const generations = document.querySelector(selector)
  if (generations) {
    const target = generations.getAttribute('data-target')
    new Vue({
      render: (h) =>
        h(Generations, {
          props: {
            target: target
          }
        })
    }).$mount(selector)
  }
})
