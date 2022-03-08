<template lang="pug">
.stamp.stamp-approve(v-if='checkId')
  h2.stamp__content.is-title
    | 確認済
  time.stamp__content.is-created-at
    | {{ checkCreatedAt }}
  .stamp__content.is-user-name
    .stamp__content-inner
      | {{ checkUserName }}
</template>
<script>
import 'whatwg-fetch'

export default {
  props: {
    checkableId: { type: String, required: true },
    checkableType: { type: String, required: true }
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
  },
  mounted() {
    this.$store.dispatch('setCheckable', {
      checkableId: this.checkableId,
      checkableType: this.checkableType
    })
  }
}
</script>
