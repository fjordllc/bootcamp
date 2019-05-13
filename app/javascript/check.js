import Vue from 'vue'
import Check from './check.vue'

document.addEventListener('DOMContentLoaded', () => {
  const check = document.getElementById('js-check')
  if (check) {
    const checkableId = check.getAttribute('data-checkable-id')
    const checkableType = check.getAttribute('data-checkable-type')
    const checkableLabel = check.getAttribute('data-checkable-label')
    new Vue({
      render: h => h(Check, { props: {
        checkableId: checkableId,
        checkableType: checkableType,
        checkableLabel: checkableLabel
      } })
    }).$mount('#js-check')
  }
})
