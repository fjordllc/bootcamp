import Vue from 'vue'
import Watch from './watch-toggle.vue'

document.addEventListener('DOMContentLoaded', () => {
  const watch = document.getElementById('js-watch-toggle')
  if (watch) {
    const watchableId = Number(watch.getAttribute('data-watchable-id'))
    const watchableType = watch.getAttribute('data-watchable-type')
    new Vue({
      render: (h) =>
        h(Watch, {
          props: {
            watchableId: watchableId,
            watchableType: watchableType
          }
        })
    }).$mount('#js-watch-toggle')
  }
})
