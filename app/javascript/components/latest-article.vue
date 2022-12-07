<template lang="pug">
.card-list-item
  .card-list-item__inner
    .card-list-item__user
      a.card-list-item__user-link(:href='latestArticle.user.url')
        img.card-list-item__user-icon.a-user-icon(
          :title='latestArticle.user.icon_title',
          :alt='latestArticle.user.icon_title',
          :src='latestArticle.user.avatar_url')
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          h2.card-list-item-title__title
            a.card-list-item-title__link.a-text-link(
              :href='latestArticle.url',
              target='_blank',
              rel='noopener')
              | {{ latestArticle.title }}
      .card-list-item__row
        .card-list-item__summary
          p
            | {{ latestArticle.summary }}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              time.a-meta
                | {{ publishedAt }}
    .card-list-item__thumbnail
      a.card-list-item__thumbnail-inner(
        :href='latestArticle.url',
        target='_blank',
        rel='noopener')
        img.card-list-item__thumbnail-image(:src='latestArticle.thumbnailUrl')
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
