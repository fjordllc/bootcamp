import Vue from 'vue'
import Grass from './grass'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-grass'
  const grass = document.querySelector(selector)
  if (grass) {
    const userId = grass.getAttribute('data-user-id')

    new Vue({
      render: (h) =>
        h(Grass, {
          props: {
            userId: userId
          }
        })
    }).$mount(selector)
  }
})
