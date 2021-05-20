<template lang="pug">
.thread-list.a-card
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
    reportId: { type: String, required: true }
  },
  data: function () {
    return {
      reports: null,
      currentUserId: null
    }
  },
  computed: {
    reportsAPI() {
      return `/api/reports/${this.reportId}.json?`
    }
  },
  created() {
    window.onpopstate = () => {
      this.getReports()
    }
    this.getReports()
  },
  methods: {
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
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
