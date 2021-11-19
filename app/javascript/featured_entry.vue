<template lang="pug">
.thread-list-item(:class='isFeaturedEntryClassName')
  .thread-list-item__inner
    .thread-list-item__label
      | {{ featuredEntry.modelNameI18n }}
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__title
            a.thread-list-item-title__link(:href='featuredEntry.url')
              | {{ featuredEntry.title }}
      .thread-list-item__row
        .thread-list-item__summary
          p {{ featuredEntry.summary }}
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              a.a-user-name(:href='featuredEntry.authorUrl')
                | {{ featuredEntry.author }}
            .thread-list-item-meta__item
              time.a-meta(:datetime='featuredEntry.updated_at')
                | {{ createdAt }}
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)
export default {
  props: {
    featuredEntry: { type: Object, required: true }
  },
  computed: {
    isfeaturedEntryClassName() {
      return `is-${this.featuredEntry.featured_entry_class_name}`
    },
    createdAt() {
      const date = this.featuredEntry.reported_on || this.featuredEntry.created_at
      return dayjs(date).format('YYYY年MM月DD日(dd) HH:mm')
    }
  }
}
</script>
