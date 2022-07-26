<template lang="pug">
.a-user-icons__item
  a.a-user-icons__item-link(:href='startedStudent.user_link')
    img(
      :class='`a-user-icons__item-icon a-user-icon ${activeOrInactive} is-${startedStudent.primary_role}`',
      :src='startedStudent.avatar_url',
      :title='`${startedStudent.icon_title}`'
    )
</template>

<script>
export default {
  props: {
    startedStudent: { type: Object, required: true }
  },
  computed: {
    activeOrInactive() {
      const active = this.startedStudent.active
      return active ? 'active' : 'inactive'
    }
  }
}
</script>
