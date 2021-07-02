<template lang="pug">
.thread-list-item(:class='isBookmarkClassName')
  .thread-list-item__inner
    .thread-list-item__label
      | {{ bookmark.modelNameI18n }}
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__title
            a.thread-list-item-title__link(:href='bookmark.url')
              | {{ bookmark.title }}
      .thread-list-item__row
        .thread-list-item__summary
            p {{ bookmark.summary }}
      .thread-list-item__row
        .thread-list-item-meta__items
          .thread-list-item-meta__item
            a.a-user-name(:href='bookmark.authorUrl')
              | {{ bookmark.author }}
          .thread-list-item-meta__item
            time.a-date(:datetime='bookmark.updated_at')
              | {{ createdAt }}
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)
export default {
  props: {
    bookmark: { type: Object, required: true }
  },
  computed: {
    isBookmarkClassName(){
     return `is-${this.bookmark.bookmark_class_name}`
    },
    createdAt() {
      const date = this.bookmark.reported_on || this.bookmark.created_at
      return dayjs(date).format(
          'YYYY年MM月DD日(dd) HH:mm'
      )
    }
  }
}
</script>
