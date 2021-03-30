import Vue from 'vue'
import EditingUserTags from './editing-user-tags.vue'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-editing-user-tags')
  if (element) {
    const tagsInitialValue = element.getAttribute('data-tags-initial-value')
    const tagsParamName = element.getAttribute('data-tags-param-name')
    const userId = element.getAttribute('data-user-id')

    new Vue({
      render: h => h(EditingUserTags, {
        props: {
          tagsInitialValue: tagsInitialValue,
          tagsParamName: tagsParamName,
          userId: userId
        }
      })
    }).$mount('#js-editing-user-tags')
  }
})
