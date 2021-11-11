<template lang="pug">
.reports.is-md(v-if='reports === null')
  loadingListPlaceholder
.reports(v-else-if='reports.length > 0 || !isUncheckedReportsPage')
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  .thread-list.a-card
    .thread-list__items
      report(
        v-for='report in reports',
        :key='report.id',
        :report='report',
        :current-user-id='currentUserId'
      )
    unconfirmed-link(v-if='isUncheckedReportsPage', label='未チェックの日報を一括で開く')
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
.o-empty-message(v-else)
  .o-empty-message__icon
    i.far.fa-smile
  p.o-empty-message__text
    | 未チェックの日報はありません
</template>
<script>
import Report from './report.vue'
import UnconfirmedLink from './unconfirmed_link.vue'
import LoadingListPlaceholder from './loading-list-placeholder.vue'
import Pager from './pager.vue'

export default {
  components: {
    report: Report,
    'unconfirmed-link': UnconfirmedLink,
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager
  },
  data() {
    return {
      reports: null,
      currentPage: this.pageParam(),
      totalPages: null,
      currentUserId: null
    }
  },
  computed: {
    isUncheckedReportsPage() {
      return location.pathname.includes('unchecked')
    },
    newParams() {
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      return params
    },
    newURL() {
      return `${location.pathname}?${this.newParams}`
    },
    reportsAPI() {
      const params = this.newParams
      if (this.isUncheckedReportsPage) {
        return `/api/reports/unchecked.json?${params}`
      } else {
        return `/api/reports.json?${params}`
      }
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
      this.getReports()
    }
    this.getReports()
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
      this.getReports()
    },
    getReports() {
      fetch(this.reportsAPI, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.reports = []
          json.reports.forEach((r) => {
            this.reports.push(r)
          })
          this.currentUserId = json.currentUserId
          this.totalPages = parseInt(json.totalPages)
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
