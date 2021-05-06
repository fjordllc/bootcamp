<template lang="pug">
.tag-links
  ul.tag-links__items(v-if='tags')
    li.tag-links__item(v-for='tag in tags')
      a.tag-links__item-link(:href='`/users/tags/${tag}`')
        | {{ tag }}
</template>
<script>
export default {
  props: {
    user: { type: Object, required: true }
  },
  data() {
    return {
      tags: this.user.tag_list
    }
  }
}
</script>

