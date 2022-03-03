<template lang="pug">
div
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  div(v-if='questions === null')
    loadingListPlaceholder
  .o-empty-message(v-else-if='questions.length === 0')
    .o-empty-message__icon
      i.far.fa-smile
    p.o-empty-message__text
      | {{ emptyMessage }}
  .thread-list.a-card(v-else)
    .thread-list__items
      question(
        v-for='question in questions',
        :key='question.id',
        :question='question'
      )
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
</template>

<script>
import LoadingListPlaceholder from './loading-list-placeholder.vue'
import Pager from './pager.vue'
import Question from './question.vue'

export default {
  components: {
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager,
    question: Question
  },
  props: {
    emptyMessage: { type: String, required: true },
    selectedTag: { type: String, required: true },
    usersPath: { type: String, default: '', required: false }
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
      return params
    },
    newURL() {
      return `${location.pathname}?${this.newParams}`
    },
    questionsAPI() {
      const params = this.newParams
      const usersPath = this.usersPath
      return `/api/${usersPath}questions.json?${params}`
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
