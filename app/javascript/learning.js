import Vue from 'vue'
import Learning from './learning.vue'

document.addEventListener('DOMContentLoaded', () => {
  const learning = document.getElementById('js-learning')
  if (learning) {
    const practiceId = learning.getAttribute('data-practice-id')
    new Vue({
      render: h => h(Learning, { props: { practiceId: practiceId } })
    }).$mount('#js-learning')
  }
})
