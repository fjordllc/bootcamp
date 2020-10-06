import Vue from 'vue'
import QuestionTags from './question_tags.vue'

document.addEventListener('DOMContentLoaded', () => {
  const questionTagsElm = document.getElementById('js-question-tags')
  if (questionTagsElm) {
    const tagsInitialValue = questionTagsElm.getAttribute('data-tags-initial-value')
    const tagsParamName = questionTagsElm.getAttribute('data-tags-param-name')
    const questionId = questionTagsElm.getAttribute('data-question-id')
    const questionUserId = questionTagsElm.getAttribute('data-question-user-id')
    const currentUserId = questionTagsElm.getAttribute('data-current-user-id')
    var adminLogin = questionTagsElm.getAttribute('data-admin-login')

    new Vue({
      render: h => h(QuestionTags, {
        props: {
          tagsInitialValue: tagsInitialValue,
          tagsParamName: tagsParamName,
          questionId: questionId,
          questionUserId: questionUserId,
          currentUserId: currentUserId,
          adminLogin: adminLogin
        }
      })
    }).$mount('#js-question-tags')
  }
})
