import Vue from 'vue'
import userSelect from './checker-select.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-checker-select'
  const checkerSelect = document.querySelector(selector)
  if (checkerSelect) {
    const checker = checkerSelect.getAttribute('data-checker')
    const checkers = checkerSelect.getAttribute('data-checkers')
    new Vue({
      render: (h) =>
        h(userSelect, {
          props: {
            checkers: checkers,
            checker: checker
          }
        })
    }).$mount(selector)
  }
})
