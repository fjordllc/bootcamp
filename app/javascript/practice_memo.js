import Vue from 'vue'
import PracticeMemo from 'practice_memo.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-practice-memo'
  const practiceMemo = document.querySelector(selector)
  if (practiceMemo) {
    const practiceId = practiceMemo.getAttribute('data-practice-id')
    new Vue({
      render: (h) =>
        h(PracticeMemo, {
          props: {
            practiceId: practiceId
          }
        })
    }).$mount(selector)
  }
})
