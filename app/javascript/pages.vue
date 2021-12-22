<template lang="pug">
.page-body
  .container.is-md(v-if='!loaded')
    loadingListPlaceholder
  .container(v-else-if='pages.length === 0')
    .o-empty-message
      .o-empty-message__icon
        i.far.fa-smile
      p.o-empty-message__text
        | {{ title }}はありません
  .container.is-xl(v-else)
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .two-columns
      .two-columns__inner
        .thread-list.a-card
          page(v-for='page in pages', :key='page.id', :page='page')
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import LoadingListPlaceholder from './loading-list-placeholder.vue'
import Page from './page.vue'
import Pager from './pager.vue'

export default {
  components: {
    loadingListPlaceholder: LoadingListPlaceholder,
    page: Page,
    pager: Pager
  },
  props: {
    title: { type: String, required: true },
    currentUserId: { type: String, required: true }
  },
  data() {
    return {
      pages: [],
      totalPages: 0,
      currentPage: Number(this.getPageValueFromParameter()) || 1,
      loaded: false,
      currentUser: {}
    }
  },
  computed: {
    url() {
      return `/api/pages?page=${this.currentPage}`
    },
    pagerProps() {
      return {
        initialPageNumber: this.currentPage,
        pageCount: this.totalPages,
        pageRange: 5,
        clickHandle: this.paginateClickCallback
      }
    }
  },
  created() {
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.getPagesPerPage()
    this.getCurrentUser()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getPagesPerPage() {
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
          this.totalPages = json.total_pages
          this.pages = []
          json.pages.forEach((page) => {
            this.pages.push(page)
          })
          this.loaded = true
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    getPageValueFromParameter() {
      const url = location.href
      const results = url.match(/\?page=(\d+)/)
      if (!results) return null
      return results[1]
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.getPagesPerPage()
      history.pushState(
        null,
        null,
        location.pathname + (pageNumber === 1 ? '' : `?page=${pageNumber}`)
      )
    },
    getCurrentUser() {
      fetch(`/api/users/${this.currentUserId}.json`, {
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
        .then((json) => {
          for (const key in json) {
            this.$set(this.currentUser, key, json[key])
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
