<template lang="pug">
.page-body
  .container(v-if="question === null")
    .empty
      .fas.fa-spinner.fa-pulse
      |  ロード中
  .container(v-else)
    questionDetail(
      v-if="currentUser !== null"
      :initialQuestion="question"
      :currentUser="currentUser"
    )
    answers(
      :questionId="questionId"
      :questionUserId="question.user.id"
      :currentUserId="currentUserId"
    )

</template>
<script>
import QuestionDetail from './question-detail.vue'
import Answers from './answers.vue'
import moment from 'moment'
moment.locale('ja')

export default {
  components: {
    questionDetail: QuestionDetail,
    answers: Answers,
  },
  props: {
    currentUserId: { type: String, required: true },
    questionId: { type: String, required: true },
  },
  data: () => {
    return {
      question: null,
      currentUser: null,
    }
  },
  async created() {
    this.question = await this.fetchQuestion()
    this.currentUser = await this.fetchUser(this.currentUserId)
  },
  methods: {
    async fetchQuestion() {
      return fetch(`/api/questions/${this.questionId}.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token(),
        },
        credentials: 'same-origin',
      })
        .then((response) => {
          return response.json()
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
          return null
        })
    },
    async fetchUser(id) {
      return fetch(`/api/users/${id}.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
        },
        credentials: 'same-origin',
        redirect: 'manual',
      })
        .then((response) => {
          return response.json()
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
          return null
        })
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
  },
}
</script>
