import Vue from 'vue'
import DocsTaggingUI from './docs-tagging-ui.vue'

document.addEventListener('DOMContentLoaded', () => {
  const docsTagging = document.getElementById('js-docs-tagging')
  console.log('docs-tagging')
  if (docsTagging) {
    new Vue({
      render: h => h(DocsTaggingUI)
    }).$mount('#js-docs-tagging')
  }
})
