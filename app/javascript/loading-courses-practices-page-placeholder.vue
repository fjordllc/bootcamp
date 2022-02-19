<template lang="pug">
.page-body__inner
  .categories-items
    .categories-items__inner
      loadingCoursesPracticesPageItemsPlaceholder(
        v-for='num in itemCount',
        :key='num'
      )
    .page-nav
      .page-nav__items
        loadingCoursesPracticesPageNavItemPlaceholder(
          v-for='num in pageNavItemCount',
          :key='num'
        )
</template>

<script>
import LoadingCoursesPracticesPageItemsPlaceholder from './loading-courses-practices-page-items-placeholder.vue'
import LoadingCoursesPracticesPageNavItemPlaceholder from './loading-cources-practices-page-nav-item-placeholder.vue'

export default {
  components: {
    loadingCoursesPracticesPageItemsPlaceholder:
      LoadingCoursesPracticesPageItemsPlaceholder,
    loadingCoursesPracticesPageNavItemPlaceholder:
      LoadingCoursesPracticesPageNavItemPlaceholder
  },
  data() {
    return {
      itemCount: 2,
      pageNavItemCount: 10
    }
  }
}
</script>
