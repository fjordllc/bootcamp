import Vue from 'vue'
import UserTags from './user_tags.vue'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-user-tags')
  if (element) {
    const tagsInitialValue = element.getAttribute('data-tags-initial-value')
    const tagsParamName = element.getAttribute('data-tags-param-name')
    const userId = element.getAttribute('data-user-id')
    const editable = element.getAttribute('editable') === 'true'

    new Vue({
      render: h => h(UserTags, {
        props: {
          tagsInitialValue: tagsInitialValue,
          tagsParamName: tagsParamName,
          userId: userId,
          editable: editable
        }
      })
    }).$mount('#js-user-tags')
  }
})
