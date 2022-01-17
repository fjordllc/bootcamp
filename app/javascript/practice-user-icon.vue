<template lang="pug">
.m-user-icons__item
  a.m-user-icons__item-link(:href='startedStudent.user_link')
    img(
      :class='`m-user-icons__item-icon a-user-icon ${activeOrInactive} is-${startedStudent.role[0]}`',
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
