<template lang="pug">
.card-list__items(v-if='reports && reports.length > 0')
  report(
    v-for='report in reports',
    :key='report.id',
    :report='report',
    :current-user-id='currentUserId',
    :display-user-icon='displayUserIcon'
  )
</template>
<script>
import Report from 'components/report.vue'

export default {
  name: 'SadReports',
  components: {
    report: Report
  },
  props: {
    displayUserIcon: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      reports: null,
      currentUserId: null
    }
  },
  created() {
    this.getSadReports()
  },
  methods: {
    async getSadReports() {
      const response = await fetch('/api/reports/sad_streak.json', {
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
