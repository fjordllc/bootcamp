import Vue from 'vue'
import CategoriesPractice from './categories-practice.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '.js-admin-category-practice'
  const categories = document.querySelectorAll(selector)
  if (categories) {
    for (let i = 0; i < categories.length; i++) {
      const id = categories[i].getAttribute('data-category-id')
      const categoriesPractices = categories[i].getAttribute('data-categories-practices')
      const categoryPractices = categories[i].getAttribute('data-practices')
      new Vue({
        render: h => h(CategoriesPractice, {
          props: {
            id: id,
            categoriesPractices: categoriesPractices,
            categoryPractices: categoryPractices
          }
        })
      }).$mount(selector)
    }
  }
})
