import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    count: 0
  },
  mutations: {
    increment (state) {
      state.count++
    }
  }
})

export default store


// import Vue from 'vue'
// import FilterByPractices from './components/filter-by-practices.vue'
// 
// document.addEventListener('DOMContentLoaded', () => {
//   const filter = '#js-books-filter-by-practices'
//   const filteringItems = document.querySelector(filter)
//   if (filteringItems) {
//     const filteringItemId = filteringItems.getAttribute('data-filtering-item-id')
//     new Vue({
//       render: (h) =>
//         h(FilterByPractices, {
//           props: {
//             filteringItemId
//           }
//         })
//     }).$mount(filter)
//   }
// })
