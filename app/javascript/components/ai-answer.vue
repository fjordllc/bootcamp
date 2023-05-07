<template lang="pug">
div
  h2 AIの解答
  div(v-html='nl2brText')
</template>
<script>
export default {
  name: 'AIAnswer',
  props: {
    text: { type: String, required: true }
  },
  computed: {
    nl2brText() {
      return this.text.replaceAll('\n', '<br>')
    }
  }
}
</script>
