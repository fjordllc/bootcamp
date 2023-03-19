import Vue from 'vue'
import Books from 'components/books'
import store from 'store/practices'

document.addEventListener('DOMContentLoaded', () =>{
  const element = document.getElementById('js-books')
  if (element) {
    const isAdmin = element.getAttribute('data-vue-is-admin:boolean')
    const isMentor = element.getAttribute('data-vue-is-mentor:boolean')
    const practiceId = element.getAttribute('data-vue-practice-id')
    new Vue({
      store,
      render: (h) => 
      h(Books, {
        props: {
          isAdmin: Boolean(isAdmin),
          isMentor: Boolean(isMentor),
          practiceId: !practiceId ? 0 : Number(practiceId)
        }
      })
    }).$mount('#js-books')
  }
})

