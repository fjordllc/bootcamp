import Vue from 'vue'
import GenerationUsers from './generation-users.vue'

document.addEventListener('DOMContentLoaded', () => {
	const selector = '#js-generation-users'
  const users = document.querySelector(selector)
  if (users) {
    const generationID = users.getAttribute('generation-id')
    new Vue({
      render: (h) =>
        h(GenerationUsers, {
          props: {
            generationID: generationID
          }
        })
    }).$mount(selector)
  }
})
