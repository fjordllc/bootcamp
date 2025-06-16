<template lang="pug">
span(:class='["a-user-role", roleClass, joiningStatusClass]')
  img.card-list-item__user-icon.a-user-icon(
    :title='user.icon_title',
    :alt='user.icon_title',
    :src='user.avatar_url')
</template>
<script>
export default {
  name: 'UserRoleStatusSpan',
  props: {
    user: { type: Object, required: true }
  },
  computed: {
    roleClass() {
      return `is-${this.user.primary_role}`
    },
    joiningStatusClass() {
      return `is-${this.user.joining_status}`
    }
  }
}
</script>
