<template lang="pug">
.category-practices-item
  .category-practices-item__header
    .category-practices-item__title
      .category-practices-item__title-link.a-placeholder
    .practice-status.category-practices-item__status.a-placeholder
  .m-user-icons
    .m-user-icons__items
      loadingCoursesPracticesPageUserIconItemPlaceholder(
        v-for='num in itemCount',
        :key='num'
      )
</template>
<script>
import LoadingCoursesPracticesPageUserIconItemPlaceholder from './loading-cources-practices-page-user-icon-item-placeholder.vue'

export default {
  components: {
    loadingCoursesPracticesPageUserIconItemPlaceholder:
      LoadingCoursesPracticesPageUserIconItemPlaceholder
  },
  data() {
    return {
      itemCount: 3
    }
  }
}
</script>
