import Vue from 'vue'
import DocsTaggingUI from './docs-tagging-ui.vue'

document.addEventListener('DOMContentLoaded', () => {
  const docsTagging = document.getElementById('js-docs-tagging')
  if (docsTagging) {
    const tagList = docsTagging.getAttribute('data-tag-list')
    new Vue({
      render: h => h(DocsTaggingUI, { props: {
        initialTagList: tagList
      } })
    }).$mount('#js-docs-tagging')
  }
})
