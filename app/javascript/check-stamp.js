import Vue from 'vue'
import CheckStamp from './check-stamp.vue'
import store from './check-store.js'

document.addEventListener('DOMContentLoaded', () => {
  const checkStamp = document.getElementById('js-check-stamp')
  if (checkStamp) {
    const checkableId = checkStamp.getAttribute('data-checkable-id')
    const checkableType = checkStamp.getAttribute('data-checkable-type')
    new Vue({
      store,
      render: h => h(CheckStamp, { props: {
        checkableId: checkableId,
        checkableType: checkableType,
      } })
    }).$mount('#js-check-stamp')
  }
})
