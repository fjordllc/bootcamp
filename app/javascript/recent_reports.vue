<template lang="pug">
  .recent-reports
    .recent-reports__items
      .recent-reports-item(v-for="report in reports")
        a.recent-reports-item__link(:href="report.url")
          img.recent-reports-item__user-icon.a-user-icon(:src="report.user.avatar_url")
          h3.recent-reports-item__title {{ report.title }}
          time.recent-reports-item__date {{ report.reported_on }}
        .recent-reports-item__checked(v-if="report.check == 'true'")
          i.fas.fa-check
    a.recent-reports__to-index(href="/reports") もっとみる
</template>
<script>
export default {
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
