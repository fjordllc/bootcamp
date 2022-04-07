<template lang="pug">
.categories-item.practices
  .categories-item__header
    .categories-item__title.a-placeholder
  .categories-item__description
    .a-long-text.is-md.a-placeholder
      p
  .categories-item__body
    .category-practices
      loadingCoursesPracticesPageItemPlaceholder(
        v-for='num in itemCount',
        :key='num'
      )
</template>

<script>
import LoadingCoursesPracticesPageItemPlaceholder from './loading-courses-practices-page-item-placeholder.vue'

export default {
  components: {
    loadingCoursesPracticesPageItemPlaceholder:
      LoadingCoursesPracticesPageItemPlaceholder
  },
  data() {
    return {
      itemCount: 3
    }
  }
}
</script>
