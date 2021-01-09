import Vue from 'vue'
import Reports from './reports.vue'
import store from './check-store.js'

import Paginate from 'vuejs-paginate'
Vue.component('paginate', Paginate)

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-reports'
  const reports = document.querySelector(selector)
  if (reports) {
    new Vue({
      store,
      render: h => h(Reports)
    }).$mount(selector)
  }
})
