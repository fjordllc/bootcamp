import Vue from 'vue'
import PageTags from './page_tags.vue'

document.addEventListener('DOMContentLoaded', () => {
  const tagsInputElm = document.getElementById('js-page-tags')
  if (tagsInputElm) {
    const tagsInitialValue = tagsInputElm.getAttribute('data-tags-initial-value')
    const tagsParamName = tagsInputElm.getAttribute('data-tags-param-name')
    const pageId = tagsInputElm.getAttribute('data-page-id')

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
