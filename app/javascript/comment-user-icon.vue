<template lang="pug">
a.card-list-item__user-icon(:href='`/users/${user_id}`')
  img.a-user-icon(:src='comment.user_icon')
</template>

<script>
export default {
  props: {
    comment: { type: Object, required: true }
  },
  data() {
    return {
      user_id: this.comment.user_id,
      user_icon: this.comment.user_icon
    }
  }
}
</script>
