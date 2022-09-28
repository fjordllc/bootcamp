<template lang="pug">
.card-list-item
  .card-list-item__inner
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          h2.card-list-item-title__title(itemprop='name')
            a.card-list-item-title__link.a-text-link(
              :href='latestArticle.url',
              itemprop='url'
            )
              | {{ latestArticle.title }}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              .a-meta
                | {{latestArticle.summary}}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              time.a-meta
                | {{publishedAt}}
    .card-list-item__image
      | 画像
</template>

<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)

export default {
  props: {
    latestArticle: { type: Object, required: true }
  },
  computed: {
    publishedAt() {
      return dayjs(this.latestArticle.published_at).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    }
  }
}
</script>
