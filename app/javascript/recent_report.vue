<template lang="pug">
.recent-reports-item
  a.recent-reports-item__link(:href='report.url')
    img.recent-reports-item__user-icon.a-user-icon(
      :src='report.user.avatar_url',
      :class='[roleClass, daimyoClass]'
    )
    h3.recent-reports-item__title {{ report.title }}
    time.recent-reports-item__date {{ report.reported_on }}
  .stamp.stamp-approve.is-sm(v-if='report.check')
    h2.stamp__content.is-title
      | 確認済
</template>
<script>
export default {
  props: {
    report: { type: Object, required: true }
  },
  computed: {
    roleClass() {
      return `is-${this.report.user.primary_role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.report.user.daimyo }
    }
  }
}
</script>
