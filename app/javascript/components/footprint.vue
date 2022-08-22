<template lang="pug">
.user-icons__item
  a.user-icons__item-link(:href='`${footprint.user.url}`')
    img.card-list-item__user-icon.a-user-icon(
      :title='footprint.user.icon_title',
      :alt='footprint.user.icon_title',
      :src='footprint.user.avatar_url',
      :class='[roleClass]'
    )
</template>
<script>
export default {
  props: {
    footprint: { type: Object, required: true }
  },
  computed: {
  	roleClass() {
      return `is-${this.footprint.user.primary_role}`
    }
  }
}
</script>