<template lang="pug">
.react-root
</template>
<script>
import React from 'react'
import { render } from 'react-dom'
import UserIcon from 'components/UserIcon'

export default {
  props: {
    user: { type: Object, required: true },
    blockClassSuffix: { type: String, required: true }
  },
  mounted() {
    render(<UserIcon user={this.user} blockClassSuffix={this.blockClassSuffix} />, this.$el)
  }
}
</script>
