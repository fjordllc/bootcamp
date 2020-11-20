import Vue from 'vue'
import UserTags from './user_tags.vue'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-user-tags')
  if (element) {
    const tagsInitialValue = element.getAttribute('data-tags-initial-value')
    const tagsParamName = element.getAttribute('data-tags-param-name')
    const tagsInput = element.getAttribute('data-tags-input') === 'on'
    const tagsInputId = element.getAttribute('data-tags-input-id')
    const tagsEditable = element.getAttribute('data-tags-editable') === 'true'
    const userId = element.getAttribute('data-user-id')
    const currentUserId = element.getAttribute('data-current-user-id')
    const adminLogin = element.getAttribute('data-admin-login')

    new Vue({
      render: h => h(UserTags, {
        props: {
          tagsInitialValue: tagsInitialValue,
          tagsParamName: tagsParamName,
          userId: userId,
          tagsEditable: tagsEditable,
          tagsInput: tagsInput,
          tagsInputId: tagsInputId,
          currentUserId: currentUserId,
          adminLogin: adminLogin
        }
      })
    }).$mount('#js-user-tags')
  }
})
