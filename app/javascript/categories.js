import Vue from 'vue'
import Categories from './categories.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-categories'
  const categories = document.querySelector(selector)
  if (categories) {
    const allCategories = categories.getAttribute('data-categories')
    new Vue({
      render: h => h(Categories, {
        props: {
          allCategories: allCategories
        }
      })
    }).$mount(selector)
  }
})
