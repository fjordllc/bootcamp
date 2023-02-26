<template lang='pug'>
div
  div {{ count }}
  button(@click='increment')
    | プラス
</template>
<script>
export default {
  computed: {
    count () {
      return this.$store.state.count
    }
  },
  methods: {
    increment () {
      this.$store.commit('increment')
    }
  }
}
</script>
