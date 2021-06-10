<template lang="pug">
.thread-list-item(:class='modelName')
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
        .thread-list-item-meta__items
          .thread-list-item-meta__item
            a.a-user-name(:href='bookmark.authorUrl')
              | {{ bookmark.author }}
          .thread-list-item-meta__item(v-if='bookmark.modelName == "Report"')
            time.a-date(:datetime='bookmark.reportedOn', pubdate='pubdate')
              | {{ bookmark.reportedOn }}の日報
</template>
<script>
export default {
  props: {
    bookmark: { type: Object, required: true }
  },
  computed: {
    modelName() {
      return `is-${this.bookmark.modelName}`
    }
  }
}
</script>
