<template lang="pug">
.page-body
  .container(v-if='question === null || currentUser === null')
    loadingQuestionPagePlaceholder
  .container.is-lg(v-else)
    questionEdit(
      :question='question',
      :answerCount='answerCount',
      :isAnswerCountUpdated='isAnswerCountUpdated',
      :currentUser='currentUser'
      @do-reload='doReload'
    )
    a#comments.a-anchor
    answers(
      :questionId='questionId',
      :questionUser='question.user',
      :currentUser='currentUser',
      @updateAnswerCount='updateAnswerCount',
      @solveQuestion='solveQuestion',
      @cancelSolveQuestion='cancelSolveQuestion'
    )
</template>
<script>
import QuestionEdit from './question-edit.vue'
import Answers from './answers.vue'
import LoadingQuestionPagePlaceholder from './loading-question-page-placeholder.vue'

export default {
  components: {
    LoadingQuestionPagePlaceholder: LoadingQuestionPagePlaceholder,
    /* app/javascript/loading-question-page-placeholder.vue */
    questionEdit: QuestionEdit,
    answers: Answers
  },
  props: {
    currentUserId: { type: String, required: true },
    questionId: { type: String, required: true }
  },
  data() {
    return {
      question: null,
      currentUser: null,
      answerCount: 0,
      isAnswerCountUpdated: false
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
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin'
      })
        .then((response) => {
          return response.json()
        })
        .then((question) => {
          this.question = question
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    fetchUser(id) {
      fetch(`/api/users/${id}.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((user) => {
          this.currentUser = user
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    solveQuestion(answer) {
      this.question.correct_answer = answer
    },
    cancelSolveQuestion() {
      this.question.correct_answer = null
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    doReload() {
      this.fetchQuestion(this.questionId)
    },
    updateAnswerCount(count) {
      this.answerCount = count
      this.isAnswerCountUpdated = true
    }
  }
}
</script>
