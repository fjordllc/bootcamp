import Vue from 'vue'
import TagsInput from './tags-input.vue'

document.addEventListener('DOMContentLoaded', () => {
  const tagsInputElm = document.getElementById('js-tags-input')
  if (tagsInputElm) {
    const tagsInitialValue = tagsInputElm.getAttribute('data-tags-initial-value')
    const tagsParamName = tagsInputElm.getAttribute('data-tags-param-name')
    const taggableType = tagsInputElm.getAttribute('data-taggable-type')
    const taggableId = tagsInputElm.getAttribute('data-taggable-id')
    const taggablePath = tagsInputElm.getAttribute('data-taggable-path')

    new Vue({
      render: h => h(TagsInput, {
        props: {
          tagsInitialValue: tagsInitialValue,
          tagsParamName: tagsParamName,
          taggableType: taggableType,
          taggableId: taggableId,
          taggablePath: taggablePath
        }
      })
    }).$mount('#js-tags-input')
  }
})
