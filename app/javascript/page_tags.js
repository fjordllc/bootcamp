import Vue from 'vue'
import PageTags from './page_tags.vue'

document.addEventListener('DOMContentLoaded', () => {
  const pageTagsElm = document.getElementById('js-page-tags')
  if (pageTagsElm) {
    const tagsInitialValue = pageTagsElm.getAttribute('data-tags-initial-value')
    const tagsParamName = pageTagsElm.getAttribute('data-tags-param-name')
    const pageId = pageTagsElm.getAttribute('data-page-id')

    new Vue({
      render: h => h(PageTags, {
        props: {
          tagsInitialValue: tagsInitialValue,
          tagsParamName: tagsParamName,
          pageId: pageId
        }
      })
    }).$mount('#js-page-tags')
  }
})
