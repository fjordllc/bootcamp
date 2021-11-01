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
          this.reports = json.reports
          this.currentUserId = json.currentUserId
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
