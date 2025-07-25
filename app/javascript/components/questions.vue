<template>
  <div>
    <nav v-if="totalPages > 1" class="pagination">
      <pager v-bind="pagerProps"></pager>
    </nav>
    <div v-if="questions === null">
      <loadingListPlaceholder></loadingListPlaceholder>
    </div>
    <div v-else-if="questions.length === 0" class="o-empty-message">
      <div class="o-empty-message__icon">
        <i class="fa-regular fa-sad-tear"></i>
      </div>
      <p class="o-empty-message__text">
        {{ emptyMessage }}
      </p>
    </div>
    <div v-else class="card-list a-card">
      <div class="card-list__items">
        <question
          v-for="question in questions"
          :key="question.id"
          :question="question"></question>
      </div>
    </div>
    <nav v-if="totalPages > 1" class="pagination">
      <pager v-bind="pagerProps"></pager>
    </nav>
  </div>
</template>

<script>
import LoadingListPlaceholder from 'loading-list-placeholder.vue'
import Pager from 'pager.vue'
import Question from 'components/question.vue'

export default {
  name: 'Questions',
  components: {
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager,
    question: Question
  },
  props: {
    emptyMessage: { type: String, required: true },
    selectedTag: { type: String, default: null, required: false },
    userId: { type: Number, default: null, required: false },
    practiceId: { type: Number, default: null, required: false }
  },
  data() {
    return {
      questions: null,
      currentPage: this.pageParam(),
      totalPages: null
    }
  },
  computed: {
    newParams() {
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      if (this.selectedTag) params.set('tag', this.selectedTag)
      if (this.userId) params.set('user_id', this.userId)
      if (this.practiceId) params.set('practice_id', this.practiceId)
      return params
    },
    newURL() {
      return `${location.pathname}?${this.newParams}`
    },
    questionsAPI() {
      const params = this.newParams
      return `/api/questions.json?${params}`
    },
    pagerProps() {
      return {
        initialPageNumber: this.currentPage,
        pageCount: this.totalPages,
        pageRange: 9,
        clickHandle: this.clickCallback
      }
    }
  },
  created() {
    window.onpopstate = () => {
      this.currentPage = this.pageParam()
      this.getQuestions()
    }
    this.getQuestions()
  },
  methods: {
    pageParam() {
      const url = new URL(location.href)
      const page = url.searchParams.get('page')
      return parseInt(page || 1)
    },
    clickCallback(pageNum) {
      this.currentPage = pageNum
      history.pushState(null, null, this.newURL)
      this.questions = null
      this.getQuestions()
      window.scrollTo(0, 0)
    },
    getQuestions() {
      fetch(this.questionsAPI, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.questions = []
          json.questions.forEach((r) => {
            this.questions.push(r)
          })
          this.totalPages = parseInt(json.totalPages)
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
