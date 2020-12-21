import Vue from 'vue'
import Categories from './categories.vue'

document.addEventListener('DOMContentLoaded', () => {
  const categories = document.getElementById('js-categories')
  if (categories) {
    const allCategories = categories.getAttribute('data-categories')
    new Vue({
      render: h => h(Categories, {
        props: {
          allCategories: allCategories
        }
      })
    }).$mount('#js-categories')
  }
})
