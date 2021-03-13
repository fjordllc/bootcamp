<template lang="pug">
  .thread-list-item__user-icon
    a(:href="`/users/${user_id}`")
      img.thread-list-item__checked-author-icon.a-user-icon(:src="comment.user_icon")
</template>

<script>
export default {
  props: ["comment"],
  data(){
    return {
      user_id: this.comment.user_id,
      user_icon: this.comment.user_icon,
    }
  },
}
</script>
