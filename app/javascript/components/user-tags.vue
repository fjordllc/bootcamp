<template lang="pug">
.tag-links
  ul.tag-links__items(v-if='tags.length !== 0')
    li.tag-links__item(v-for='tag in tags', :key='tag')
      a.tag-links__item-link(:href='`/users/tags/${encodeURIComponent(tag)}`')
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
