<template lang="pug">
div
  template(v-if='question === null || currentUser === null')
    commentPlaceholder(v-for='num in placeholderCount', :key='num')
  template(v-else)
    template(v-if='hasAiQuestion && isAdminOrMentor()')
      ai_answer(:text='question.ai_answer')
    answers(
      :questionId='questionId',
      :questionUser='question.user',
      :currentUser='currentUser',
      @updateAnswerCount='updateAnswerCount',
      @solveQuestion='solveQuestion',
      @cancelSolveQuestion='cancelSolveQuestion')
</template>
<script>
import CSRF from 'csrf'
import AIAnswer from 'components/ai-answer.vue'
import Answers from '../answers.vue'
import CommentPlaceholder from '../comment-placeholder.vue'

export default {
  name: 'Answers',
  components: {
    commentPlaceholder: CommentPlaceholder,
    ai_answer: AIAnswer,
    answers: Answers
  },
  props: {
    currentUserId: { type: Number, required: true },
    questionId: { type: String, required: true }
  },
  data() {
    return {
      question: null,
      currentUser: null,
      placeholderCount: 3
    }
  },
  computed: {
    hasAiQuestion() {
      return (
        this.question.ai_answer !== null && this.question.ai_answer.length > 0
      )
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
          'X-CSRF-Token': CSRF.getToken()
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
    solveQuestion() {
      const statusLabel = document.querySelector('.js-solved-status')
      statusLabel.classList.remove('is-danger')
      statusLabel.classList.add('is-success')
      statusLabel.textContent = '解決済'
    },
    cancelSolveQuestion() {
      const statusLabel = document.querySelector('.js-solved-status')
      statusLabel.classList.remove('is-success')
      statusLabel.classList.add('is-danger')
      statusLabel.textContent = '未解決'
    },
    updateAnswerCount(count) {
      const answerCount = document.querySelector('.js-answer-count')
      answerCount.textContent = count
    },
    isAdminOrMentor() {
      return (
        this.currentUser.roles.includes('admin') ||
        this.currentUser.roles.includes('mentor')
      )
    }
  }
}
</script>
