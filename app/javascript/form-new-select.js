import Vue from 'vue'
import FormNewSelect from './form-new-select.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = "#js-form-new-select"
  const practiceSelect = document.querySelector(selector)
  // 上の要素の data　属性の値をここで取得して, 変数に代入
  const practices = practiceSelect.getAttribute("data-practices")
  new Vue({
    render: (h) =>
      h(FormNewSelect, {
        props:
          {practices: practices}
      })
  }).$mount(selector)
})
