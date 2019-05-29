<template lang="pug">
  .stamp.stamp-approve(v-if="checkId")
    h2.stamp__content.is-title
      | 確認済
    time.stamp__content.is-created-at
      | {{ checkCreatedAt }}
    .stamp__content.is-user-name
      | {{ checkUserName }}
</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['checkableId', 'checkableType', 'checkableLabel'],
  mounted () {
    this.$store.dispatch('setCheckable', {
      checkableId: this.checkableId,
      checkableType: this.checkableType
    })
  },
  computed: {
    checkId() {
      return this.$store.getters.checkId
    },
    checkCreatedAt() {
      return this.$store.getters.createdAt
    },
    checkUserName() {
      return this.$store.getters.userName
    }
  }
}
</script>
