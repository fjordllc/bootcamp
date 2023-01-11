<template lang="pug">
.react-root
</template>
<script>
import React from 'react'
import { render } from 'react-dom'
import UnconfirmedLink from 'components/UnconfirmedLink'

export default {
  props: {
    label: { type: String, required: true }
  },
  mounted() {
    render(<UnconfirmedLink label={this.label} />, this.$el)
  }
}
</script>
