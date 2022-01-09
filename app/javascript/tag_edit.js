import Vue from 'vue'
import TagEditButton from './tag-edit-button.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-tag-edit'
  const tagEdit = document.querySelector(selector)
  if (tagEdit) {
    const tagId = tagEdit.getAttribute('tag-id')
    const tagName = tagEdit.getAttribute('tag-name')
    new Vue({
      render: (h) =>
        h(TagEditButton, {
          props: {
            tagId: tagId,
            tagNameProp: tagName
          }
        })
    }).$mount(selector)
  }
})
