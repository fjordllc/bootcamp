import Vue from 'vue'
import Grass from './grass'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-grass'
  const grass = document.querySelector(selector)
  if (grass) {
    const currentUser = window.currentUser
    const userId = grass.getAttribute('data-user-id')

    new Vue({
      render: (h) =>
        h(Grass, {
          props: {
            currentUser: currentUser,
            userId: userId
          }
        })
    }).$mount(selector)
  }
})
