import Vue from 'vue'
import Searchables from './searchables.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-searchables'
  const searchables = document.querySelector(selector)
  if (searchables) {
    const document_type = searchables.getAttribute('document_type')
    const word = searchables.getAttribute('word')
    new Vue({
      render: h => h(Searchables, {
        props: {document_type: document_type, word: word }
      })
    }).$mount(selector)
  }
})
