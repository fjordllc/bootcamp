<template lang="pug">
.card-list.a-card
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
</template>
<script>
import Report from './report.vue'

export default {
  name: 'UserRecentReports',
  components: {
    report: Report
  },
  props: {
    userId: {
      type: Number,
      default: null
    },
    limit: {
      type: Number,
      default: 10
    }
  },
  data() {
    return {
      reports: null,
      currentUserId: null
    }
  },
  computed: {
    newParams() {
      const params = new URL(location.href).searchParams
      if (this.userId) {
        params.set('user_id', this.userId)
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
      return `/api/reports.json?${params}`
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
