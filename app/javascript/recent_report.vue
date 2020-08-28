<template lang="pug">
  .recent-reports-item
    a.recent-reports-item__link(:href="report.url")
      img.recent-reports-item__user-icon.a-user-icon(:src="report.user.avatar_url" :class="[roleClass, daimyoClass]")
      h3.recent-reports-item__title {{ report.title }}
      time.recent-reports-item__date {{ report.reported_on }}
    .recent-reports-item__checked(v-if="report.check == 'true'")
      i.fas.fa-check
</template>
<script>
export default {
  props: ['report'],
  computed: {
    roleClass() {
      return `is-${this.report.user.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.report.user.daimyo }
    }
  }
}
</script>
