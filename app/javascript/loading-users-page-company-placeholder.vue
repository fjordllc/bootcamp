<template lang="pug">
.user-group
  header.user-group__header
    h2.group-company-name
      .group-company-name__link
        span.group-company-name__icon
          .group-company-name__icon-image.a-placeholder
        span.group-company-name__name
          span.group-company-name__label.a-placeholder
          span.group-company-name__label-option.a-placeholder
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
      userIconCount: 16
    }
  }
}
</script>
