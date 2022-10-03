<template lang="pug">
.card-list.a-card(v-if='limit')
  .card-header.is-sm
    h2.card-header__title
      | 直近の日報
  .card-list__items(v-if='reports && reports.length > 0')
    report(
      v-for='report in reports',
      :key='report.id',
      :report='report',
      :current-user-id='currentUserId'
    )
  .card-body(v-else)
    .card__description
      .o-empty-message
        .o-empty-message__icon
          i.fa-regular.fa-sad-tear
        .o-empty-message__text
          | 日報はまだありません。
.page-content.reports(v-else)
  .reports.is-md(v-if='reports === null')
    loadingListPlaceholder
  .card-list.a-card(v-else-if='reports.length > 0')
    .card-list__items
      report(
        v-for='report in reports',
        :key='report.id',
        :report='report',
        :current-user-id='currentUserId'
      )
    unconfirmed-link(v-if='isUncheckedReportsPage', label='未チェックの日報を一括で開く')
  .o-empty-message(v-else-if='reports.length === 0 && isUncheckedReportsPage')
    .o-empty-message__icon
      i.fa-regular.fa-smile
    p.o-empty-message__text
      | 未チェックの日報はありません
  .o-empty-message(v-else)
    .o-empty-message__icon
      i.fa-regular.fa-sad-tear
    .o-empty-message__text
      | 日報はまだありません。
</template>
<script>
import Report from 'components/report.vue'
import UnconfirmedLink from 'unconfirmed_link.vue'
import LoadingListPlaceholder from 'loading-list-placeholder.vue'

export default {
  name: 'UserRecentReports',
  components: {
    report: Report,
    'unconfirmed-link': UnconfirmedLink,
    loadingListPlaceholder: LoadingListPlaceholder
  },
  props: {
    userId: {
      type: Number,
      default: null
    },
    companyId: {
      type: Number,
      default: null
    },
    practiceId: {
      type: Number,
      default: null
    },
    limit: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      reports: null,
      currentUserId: null
    }
  },
  computed: {
    isUncheckedReportsPage() {
      return location.pathname.includes('unchecked')
    },
    newParams() {
      const params = new URL(location.href).searchParams
      if (this.userId) {
        params.set('user_id', this.userId)
      }
      if (this.companyId) {
        params.set('company_id', this.companyId)
      }
      if (this.practiceId) {
        params.set('practice_id', this.practiceId)
      }
      if (this.limit) {
        params.set('limit', this.limit)
      }
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
    }
  },
  created() {
    this.getReports()
  },
  methods: {
    async getReports() {
      const response = await fetch(this.reportsAPI, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      }).catch((error) => console.warn(error))
      const json = await response.json().catch((error) => console.warn(error))
      this.reports = json.reports
      this.currentUserId = json.currentUserId
    }
  }
}
</script>
