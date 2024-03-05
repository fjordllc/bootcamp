import Vue from 'vue'
import Generations from 'generations.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-generations'
  const generations = document.querySelector(selector)
  if (generations) {
    const target = generations.getAttribute('data-target')
    const currentUserId = generations.getAttribute('data-current-user-id:number')
    new Vue({
      render: (h) =>
        h(Generations, {
          props: {
            target: target,
            currentUserId: currentUserId
          }
        })
    }).$mount(selector)
  }
})
