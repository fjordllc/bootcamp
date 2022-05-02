import Vue from 'vue'
import WatchToggle from 'watch-toggle.vue'

document.addEventListener('DOMContentLoaded', () => {
  const watchToggle = document.getElementById('js-watch-toggle')
  if (watchToggle) {
    const watchableId = Number(watchToggle.getAttribute('data-watchable-id'))
    const watchableType = watchToggle.getAttribute('data-watchable-type')
    new Vue({
      render: (h) =>
        h(WatchToggle, {
          props: {
            watchableId: watchableId,
            watchableType: watchableType
          }
        })
    }).$mount('#js-watch-toggle')
  }
})
