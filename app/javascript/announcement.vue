<template lang="pug">
.card-list-item(:class='announcement.wip ? "is-wip" : ""')
  .card-list-item__inner
    .card-list-item__user
      a.card-list-item__user-link(:href='announcement.user.url')
        img.card-list-item__user-icon.a-user-icon(
          :title='announcement.user.icon_title',
          :alt='announcement.user.icon_title',
          :src='announcement.user.avatar_url',
          :class='[roleClass, daimyoClass]'
        )
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          .a-list-item-badge.is-wip(v-if='announcement.wip')
            span
              | WIP
          h2.card-list-item-title__title
            a.card-list-item-title__link.a-text-link(:href='announcement.url')
              | {{ announcement.title }}
      .card-list-item__row
        a.a-user-name(:href='announcement.user.url')
          | {{ announcement.user.long_name }}
      .card-list-item__row
        .card-list-item-meta__items
          .card-list-item-meta__item
            .a-meta(v-if='announcement.wip')
              | {{ title }}作成中
            time.a-meta(v-else, datetime='announcement.published_at_date_time')
              span.a-meta__label
                | 公開
              span.a-meta__value
                | {{ announcement.published_at }}
          .card-list-item-meta__item
            .a-meta
              | コメント（{{ announcement.commentsSize }}）
</template>
<script>
export default {
  props: {
    title: { type: String, required: true },
    announcement: { type: Object, required: true },
    currentUser: { type: Object, required: true }
  },
  computed: {
    roleClass() {
      return `is-${this.announcement.user.primary_role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.announcement.user.daimyo }
    }
  }
}
</script>
