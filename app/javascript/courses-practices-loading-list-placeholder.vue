<template lang="pug">
.page-body__inner
  .categories-items
    .categories-items__inner
      coursesPracticesLoadingListItemPlaceholder(
        v-for='num in itemCount',
        :key='num'
      )
    .page-nav
      .page-nav__items
        .page-nav__item
          .page-nav__item-link
            .page-nav__item-link-inner.a-placeholder
        .page-nav__item
          .page-nav__item-link
            .page-nav__item-link-inner.a-placeholder
        .page-nav__item
          .page-nav__item-link
            .page-nav__item-link-inner.a-placeholder
        .page-nav__item
          .page-nav__item-link
            .page-nav__item-link-inner.a-placeholder
        .page-nav__item
          .page-nav__item-link
            .page-nav__item-link-inner.a-placeholder
        .page-nav__item
          .page-nav__item-link
            .page-nav__item-link-inner.a-placeholder
        .page-nav__item
          .page-nav__item-link
            .page-nav__item-link-inner.a-placeholder
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
