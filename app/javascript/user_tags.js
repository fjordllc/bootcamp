import Vue from 'vue'
import Tags from 'tags.vue'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-user-tags')
  if (element) {
    const tagsInitialValue = element.getAttribute('data-tags-initial-value')
    const tagsParamName = element.getAttribute('data-tags-param-name')
    const tagsInputId = element.getAttribute('data-tags-input-id')
    const userId = element.getAttribute('data-user-id')
    const currentUserId = element.getAttribute('data-current-user-id')
    const tagsEditable = userId === currentUserId

    new Vue({
      render: (h) =>
        h(Tags, {
          props: {
            tagsInitialValue: tagsInitialValue,
            tagsParamName: tagsParamName,
            tagsInputId: tagsInputId,
            tagsTypeId: userId,
            tagsEditable: tagsEditable,
            tagsType: 'User'
          }
        })
    }).$mount('#js-user-tags')
  }
})
