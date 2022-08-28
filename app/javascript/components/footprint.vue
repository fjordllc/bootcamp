<template lang="pug">
li.user-icons__item
  a.user-icons__item-link(:href='`${footprint.user.url}`')
    img.a-user-icon.is-sm(
      :title='footprint.user.icon_title',
      :alt='footprint.user.icon_title',
      :src='footprint.user.avatar_url',
      :class='[`is-${this.footprint.user.login_name} is-${this.footprint.user.primary_role}`]'
    )
</template>
<script>
export default {
  props: {
    footprint: { type: Object, required: true }
  },
  computed: {
    roleClass() {
      return `is-${this.footprint.user.login_name.primary_role}`
    }
  }
}
</script>
