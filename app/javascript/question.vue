<template lang="pug">
.page-body
  .container(
    v-if="question === null || currentUser === null"
  )
    .empty
      .fas.fa-spinner.fa-pulse
      | ロード中
  .container(v-else)
    questionEdit(
      :question="question",
      :currentUser="currentUser"
    )
    answers(
      :questionId="questionId",
      :questionUser="question.user",
      :currentUser="currentUser"
    )
</template>
<script>
import QuestionEdit from './question-edit.vue'
import Answers from './answers.vue'
import moment from 'moment'
moment.locale('ja')

export default {
  components: {
    questionEdit: QuestionEdit,
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
  created() {
    this.fetchQuestion(this.questionId)
    this.fetchUser(this.currentUserId)
  },
  methods: {
    fetchQuestion(id) {
      fetch(`/api/questions/${id}.json`, {
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
        .then((question) => {
          this.question = question
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    fetchUser(id) {
      fetch(`/api/users/${id}.json`, {
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
        .then((user) => {
          this.currentUser = user
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
  },
}
</script>
