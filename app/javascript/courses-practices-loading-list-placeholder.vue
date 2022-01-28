<template lang="pug">
.thread-list.a-card.is-loading
  coursesPracticesLoadingListItemPlaceholder(
    v-for='num in itemCount',
    :key='num'
  )
</template>

<script>
import CoursesPracticesLoadingListItemPlaceholder from './courses-practices-loading-list-item-placeholder.vue'

export default {
  components: {
    coursesPracticesLoadingListItemPlaceholder:
      CoursesPracticesLoadingListItemPlaceholder
  },
  data() {
    return {
      itemCount: 8
    }
  }
}
</script>
