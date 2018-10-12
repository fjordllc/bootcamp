import Vue from 'vue'
import Faces from './faces.vue'

document.addEventListener('DOMContentLoaded', () => {
  const faces = document.getElementById('js-faces')
  if (faces) {
    new Vue({
      render: h => h(Faces)
    }).$mount('#js-faces')
  }
})
