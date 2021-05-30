import Vue from 'vue'
import Tags from './tags.vue'

document.addEventListener('DOMContentLoaded', () => {
  const pageTagsElm = document.getElementById('js-page-tags')
  if (pageTagsElm) {
    const tagsInitialValue = pageTagsElm.getAttribute('data-tags-initial-value')
    const tagsParamName = pageTagsElm.getAttribute('data-tags-param-name')
    const tagsInputId = pageTagsElm.getAttribute('data-tags-input-id')
    const pageId = pageTagsElm.getAttribute('data-page-id')
    const updateCallback = function (tagsValue, token) {
      const params = {
        page: {
          tag_list: tagsValue
        }
      }
      return fetch(`/api/pages/${pageId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      }).catch((error) => {
        console.warn('Failed to parsing', error)
      })
    }

    new Vue({
      render: (h) =>
        h(Tags, {
          props: {
            tagsInitialValue: tagsInitialValue,
            tagsParamName: tagsParamName,
            tagsInputId: tagsInputId,
            tagsPath: 'tags',
            tagsEditable: true,
            tagsType: 'Page',
            updateCallback: updateCallback
          }
        })
    }).$mount('#js-page-tags')
  }
})
