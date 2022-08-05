<template lang="pug">
.category-practices-item
  .category-practices-item__header
    .category-practices-item__title
      .category-practices-item__title-link.a-placeholder
    .practice-status.category-practices-item__status.a-placeholder
  .a-user-icons
    .a-user-icons__items
      loadingUserIconPlaceholder(
        v-for='num in userIconCount',
        :key='num'
      )
</template>
<script>
import LoadingUserIconPlaceholder from 'loading-user-icon-placeholder.vue'

export default {
  components: {
    loadingUserIconPlaceholder:
      LoadingUserIconPlaceholder
  },
  data() {
    return {
      userIconCount: 3
    }
  }
}
</script>
