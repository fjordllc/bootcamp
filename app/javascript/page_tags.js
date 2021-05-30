import Vue from 'vue'
import Tags from './tags.vue'

document.addEventListener('DOMContentLoaded', () => {
  const pageTagsElm = document.getElementById('js-page-tags')
  if (pageTagsElm) {
    const tagsInitialValue = pageTagsElm.getAttribute('data-tags-initial-value')
    const tagsParamName = pageTagsElm.getAttribute('data-tags-param-name')
    const tagsInputId = pageTagsElm.getAttribute('data-tags-input-id')
    const pageId = pageTagsElm.getAttribute('data-page-id')

    new Vue({
      render: (h) =>
        h(Tags, {
          props: {
            tagsInitialValue: tagsInitialValue,
            tagsParamName: tagsParamName,
            tagsInputId: tagsInputId,
            tagsTypeId: pageId,
            tagsPath: 'tags',
            tagsEditable: true,
            tagsType: 'Page',
            lowerTagsType: 'page'
          }
        })
    }).$mount('#js-page-tags')
  }
})
