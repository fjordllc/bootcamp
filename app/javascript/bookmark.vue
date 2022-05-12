<template lang="pug">
.card-list-item(:class='isBookmarkClassName')
  .card-list-item__inner
    .card-list-item__label
      | {{ bookmark.modelNameI18n }}
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          .card-list-item-title__title
            a.card-list-item-title__link.a-text-link(:href='bookmark.url')
              | {{ bookmark.title }}
      .card-list-item__row
        .card-list-item__summary
          p {{ bookmark.summary }}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              a.a-user-name(:href='bookmark.authorUrl')
                | {{ bookmark.author }}
            .card-list-item-meta__item
              time.a-meta(:datetime='bookmark.updated_at')
                | {{ createdAt }}
    .card-list-item__option(v-if='checked')
      bookmarkButton(
        :checked='checked',
        :bookmarkableType='bookmark.modelName',
        :bookmarkableId='bookmark.bookmarkable_id',
        :bookmarkIndexId='bookmark.id',
        @update-index='$listeners["updateIndex"]'
      )
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
import bookmarkButton from 'bookmark-button.vue'
dayjs.locale(ja)
export default {
  components: {
    bookmarkButton: bookmarkButton
  },
  props: {
    bookmark: { type: Object, required: true },
    checked: { type: Boolean }
  },
  computed: {
    isBookmarkClassName() {
      return `is-${this.bookmark.bookmark_class_name}`
    },
    createdAt() {
      const date = this.bookmark.reported_on || this.bookmark.created_at
      return dayjs(date).format('YYYY年MM月DD日(dd) HH:mm')
    }
  }
}
</script>
