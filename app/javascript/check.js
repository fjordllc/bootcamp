import Vue from 'vue'
import Check from 'check.vue'
import store from 'check-store.js'

document.addEventListener('DOMContentLoaded', () => {
  const check = document.getElementById('js-check')
  if (check) {
    const checkableId = Number(check.getAttribute('data-checkable-id'))
    const checkableType = check.getAttribute('data-checkable-type')
    const checkableLabel = check.getAttribute('data-checkable-label')
    const checkerId = Number(check.getAttribute('data-checker-id'))
    const checkerName = check.getAttribute('data-checker-name')
    const checkerAvatar = check.getAttribute('data-checker-avatar')
    const currentUserId = check.getAttribute('data-current-user-id')
    new Vue({
      store,
      render: (h) =>
        h(Check, {
          props: {
            checkableId: checkableId,
            checkableType: checkableType,
            checkableLabel: checkableLabel,
            checkerId: checkerId,
            checkerName: checkerName,
            checkerAvatar: checkerAvatar,
            currentUserId: currentUserId
          }
        })
    }).$mount('#js-check')
  }
})
