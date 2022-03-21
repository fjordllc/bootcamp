<template lang="pug">
div
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  div(v-if='answers === null')
    loadingListPlaceholder
    .thread-list.a-card
  .o-empty-message(v-else-if='answers.length === 0')
    .o-empty-message__icon
      i.far.fa-sad-tear
    p.o-empty-message__text
      | 回答はまだありません。
  .thread-list.a-card(v-else)
    usersAnswer(
      v-for='answer in answers',
      :key='answer.id',
      :answer='answer'
    )
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')

</template>

<script>
import LoadingListPlaceholder from './loading-list-placeholder.vue'
import Pager from './pager.vue'
import UsersAnswer from './users-answer.vue'

export default {
  components: {
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager,
    usersAnswer: UsersAnswer
  },
  props: {
    usersPath: { type: String, default: null, required: false }
  },
  data() {
    return {
      answers: null,
      currentPage: this.pageParam(),
      totalPages: null
    }
  },
  computed: {
    newParams() {
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      return params
    },
    newURL() {
      return `${location.pathname}?${this.newParams}`
    },
    usersAnswersAPI() {
      const params = this.newParams
      const usersPath = this.usersPath
      return `/api/${usersPath}answers.json?${params}`
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
      this.getUsersAnswers()
    }
    this.getUsersAnswers()
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
      this.usersAnswers = null
      this.getUsersAnswers()
    },
    getUsersAnswers() {
      fetch(this.usersAnswersAPI, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      })
          .then((response) => {
            return response.json()
          })
          .then((json) => {
            this.answers = []
            json.answers.forEach((r) => {
              this.answers.push(r)
              console.log(this.answers)
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
