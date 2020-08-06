import Vue from 'vue'
import TagsInput from './tags-input.vue'

document.addEventListener('DOMContentLoaded', () => {
  const tagsInputElm = document.getElementById('js-tags-input')
  if (tagsInputElm) {
    const tagsInitialValue = tagsInputElm.getAttribute('data-tags-initial-value')
    const tagsParamName = tagsInputElm.getAttribute('data-tags-param-name')
    const taggableType = tagsInputElm.getAttribute('data-taggable-type')
    new Vue({
      render: h => h(TagsInput, { props: {
        tagsInitialValue: tagsInitialValue,
        tagsParamName: tagsParamName,
        taggableType: taggableType
      } })
    }).$mount('#js-tags-input')
  }
})
