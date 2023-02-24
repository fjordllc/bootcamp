<template lang='pug'>
div
  div {{ count }}
  button(@click='this.$store.commit("increment")')
    | プラス
</template>
<script>
export default {
  computed: {
    count () {
      return this.$store.state.count
    }
  },
  method: {
    increment () {
      this.$store.commit('increment')
    }
  }
}
</script>
