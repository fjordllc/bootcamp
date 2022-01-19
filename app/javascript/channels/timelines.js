import ActionCable from 'actioncable'
import Vue from 'vue'
import Timelines from './timelines-channel.vue'

document.addEventListener('DOMContentLoaded', () => {
  const timelines = document.getElementById('js-timelines')
  if (timelines) {
    const cable = ActionCable.createConsumer()
    Vue.prototype.$cable = cable

    new Vue({
      render: h => h(Timelines)
    }).$mount('#js-timelines')
  }
})
