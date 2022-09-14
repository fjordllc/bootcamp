<template lang="pug">
.page-content.loaing(v-if='!loaded')
  | ロード中
.page-content.loaded(v-else)
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  .card-list.a-card
    regularEvent(
      v-for='regularEvent in regularEvents',
      :key='regularEvent.id',
      :regularEvent='regularEvent'
    )
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
</template>

<script>
import RegularEvent from 'regular-event'
import Pager from 'pager'

export default {
  components: {
    regularEvent: RegularEvent,
    pager: Pager
  },
  data() {
    return {
      regularEvents: [],
      totalPages: 0,
      currentPage: this.getCurrentPage(),
      loaded: false
    }
  },
  computed: {
    url() {
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      return `/api/regular_events?${params}`
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
    window.onpopstate = () => {
      this.currentPage = this.getCurrentPage()
      this.getEventsPerPage()
    }
    this.getEventsPerPage()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getEventsPerPage() {
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
        .then((response) => response.json())
        .then((json) => {
          this.regularEvents = json.regular_events
          this.totalPages = json.total_pages
          this.loaded = true
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    getCurrentPage() {
      const params = new URLSearchParams(location.search)
      const page = params.get('page')
      return parseInt(page) || 1
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.getEventsPerPage()

      const url = new URL(location.href)
      if (pageNumber === 1) {
        url.searchParams.delete('page')
      } else {
        url.searchParams.set('page', pageNumber)
      }
      history.pushState(history.state, '', url)
      window.scrollTo(0, 0)
    }
  }
}
</script>
