import Vue from 'vue'
import Watch from './watch.vue'

document.addEventListener('DOMContentLoaded', () => {
  const watch = document.getElementById('js-watch')
  if (watch) {
    const watchableId = watch.getAttribute('data-watchable-id')
    const watchableType = watch.getAttribute('data-watchable-type')
    new Vue({
      render: h => h(Watch, { props: {
        watchableId: watchableId,
        watchableType: watchableType
      } })
    }).$mount('#js-watch')
  }
})
