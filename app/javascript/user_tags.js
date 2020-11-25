import Vue from 'vue'
import UserTags from './user_tags.vue'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-user-tags')
  if (element) {
    const tagsInitialValue = element.getAttribute('data-tags-initial-value')
    const tagsParamName = element.getAttribute('data-tags-param-name')
    const tagsInputId = element.getAttribute('data-tags-input-id')
    const userId = element.getAttribute('data-user-id')

    new Vue({
      render: h => h(UserTags, {
        props: {
          tagsInitialValue: tagsInitialValue,
          tagsParamName: tagsParamName,
          tagsInputId: tagsInputId,
          userId: userId
        }
      })
    }).$mount('#js-user-tags')
  }
})
