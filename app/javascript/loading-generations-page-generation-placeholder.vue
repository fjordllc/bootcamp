<template lang="pug">
.user-group
  header.user-group__header
    h2.user-group__title
      .user-group__title-link
        span.user-group__title-label.a-placeholder
        .user-group__date.a-placeholder
  .a-user-icons
    .a-user-icons__items
      loadingUserIconPlaceholder(v-for='num in userIconCount', :key='num')
</template>

<script>
import LoadingUserIconPlaceholder from 'loading-user-icon-placeholder.vue'

export default {
  components: {
    loadingUserIconPlaceholder: LoadingUserIconPlaceholder
  },
  data() {
    return {
      userIconCount: 30
    }
  }
}
</script>
