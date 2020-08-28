<template lang="pug">
  .recent-reports
    .recent-reports__items
      recent-report(v-for="(report, index) in reports"
        :key="report.id"
        :report="report")
    a.recent-reports__to-index(href="/reports") もっとみる
</template>
<script>
import RecentReport from './recent_report.vue'

export default {
  components: {
    'recent-report': RecentReport
  },
  data: () => {
    return {
      reports: []
    }
  },
  created() {
    fetch('/api/reports/recents.json', {
      method: 'GET',
      headers: { 'X-Requested-With': 'XMLHttpRequest', },
      credentials: 'same-origin',
      redirect: 'manual'
    })
        .then(response => {
          return response.json()
        })
        .then(json => {
          json.forEach(r => { this.reports.push(r) })
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
  }
}
</script>
