<template lang="pug">
.page-body
  .container.is-md(v-if='!loaded')
    loadingListPlaceholder
  .container(v-else-if='talks.length === 0')
    | 未返信の相談部屋はありません
  .container.is-md(v-else)
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .thread-list.a-card
      talk(
        v-for='talk in talks',
        :key='talk.id',
        :user='talk.user',
        :talk='talk'
      )
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>
<script>
import Talk from './talk.vue'
import LoadingListPlaceholder from './loading-list-placeholder.vue'
import Pager from './pager.vue'

export default {
  components: {
    talk: Talk,
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager
  },
  data() {
    return {
      talks: [],
      currentPage: this.pageParam(),
      loaded: false,
      totalPages: null
    }
  },
  computed: {
    isUnrepliedTalksPage() {
      return location.pathname.includes('unreplied')
    },
    url() {
      const params = this.newParams
      if (this.isUnrepliedTalksPage) {
        return `/api/talks/unreplied.json?${params}`
      } else {
        return `/api/talks.json?${params}`
      }
    },
    newParams() {
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      return params
    },
    pagerProps() {
      return {
        initialPageNumber: this.currentPage,
        pageCount: this.totalPages,
        pageRange: 9,
        clickHandle: this.clickCallback
      }
    },
    newURL() {
      return `${location.pathname}?${this.newParams}`
    }
  },
  created() {
    this.currentPage = this.pageParam()
    this.getTalks()
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
      this.getTalks()
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getTalks() {
      fetch(this.url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.talks = []
          json.talks.forEach((talk) => {
            this.talks.push(talk)
          })
          this.totalPages = json.totalPages
          this.loaded = true
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
