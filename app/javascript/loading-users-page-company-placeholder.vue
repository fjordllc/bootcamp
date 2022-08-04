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
      loadingUsersPageCompanyUserIconPlaceholder(
        v-for='num in userIconCount',
        :key='num'
      )
</template>

<script>
import LoadingUsersPageCompanyUserIconPlaceholder from 'loading-users-page-company-user-icon-placeholder.vue'

export default {
  components: {
    loadingUsersPageCompanyUserIconPlaceholder:
      LoadingUsersPageCompanyUserIconPlaceholder
  },
  data() {
    return {
      userIconCount: 16
    }
  }
}
</script>
