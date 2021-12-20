<template lang="pug">
.thread-list.a-card
  .card-header.is-sm
    h2.card-header__title
      | 直近の日報
  .thread-list__items.has-no-author-image
    report(
      v-for='report in reports',
      :key='report.id',
      :report='report',
      :current-user-id='currentUserId'
    )
</template>

<script>
import Report from './report.vue'
export default {
  components: {
    report: Report
  },
  props: {
    userID: { type: String, required: true }
  },
  data: function () {
    return {
      reports: null,
      currentUserId: null
    }
  },
  computed: {
    reportsAPI() {
      return `/api/users/${this.userID}/recent_reports.json`
    }
  },
  created() {
    window.onpopstate = () => {
      this.getReports()
    }
    this.getReports()
  },
  methods: {
    async getReports() {
      const response = await fetch(this.reportsAPI, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      }).catch(error => console.warn(error))
      const json = await response.json().catch(error => console.warn(error))
      this.reports = json.reports
      this.currentUserId = json.currentUserId
    }
  }
}
</script>
