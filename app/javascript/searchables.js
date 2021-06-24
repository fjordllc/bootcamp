import Vue from 'vue'
import Searchables from './searchables.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-searchables'
  const searchables = document.querySelector(selector)
  if (searchables) {
    const documentType = searchables.getAttribute('document_type')
    const word = searchables.getAttribute('word')
    new Vue({
      render: (h) =>
        h(Searchables, {
          props: { documentType: documentType, word: word }
        })
    }).$mount(selector)
  }
})
