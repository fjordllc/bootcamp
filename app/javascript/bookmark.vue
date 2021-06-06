<template lang="pug">
.thread-list-item(:class='modelName')
  .thread-list-item__inner
    .thread-list-item__label
      | {{ bookmark.model_name_i18n }}
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__title
            a.thread-list-item-title__link(:href='bookmark.url')
              | {{ bookmark.title }}
    .thread-list-item__row
      .thread-list-item-meta__items
        .thread-list-item-meta__item
          .a-user-name
            | {{ bookmark.user_name }}
</template>
<script>
export default {
  props: {
    bookmark: { type: Object, required: true }
  },
  computed: {
    modelName() {
      return `is-${this.bookmark.model_name}`
    }
  }
}
</script>
