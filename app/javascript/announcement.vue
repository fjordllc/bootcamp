<template lang="pug">
.thread-list-item(:class='announcement.wip ? "is-wip" : ""')
  .thread-list-item__inner
    .thread-list-item__author
      a.a-user-name(:href='announcement.user.url')
        img.thread-list-item__user-icon.a-user-icon(
          :title='announcement.user.icon_title',
          :alt='announcement.user.icon_title',
          :src='announcement.user.avatar_url',
          :class='[roleClass, daimyoClass]'
        )
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__icon.is-wip(v-if='announcement.wip') WIP
          h2.thread-list-item-title__title
            a.thread-list-item-title__link(:href='announcement.url')
              | {{ announcement.title }}
      .thread-list-item__row
        .thread-list-item-meta__items
          .thread-list-item-meta__item
            .thread-list-item-meta(v-if='announcement.wip')
              .a-meta
                | {{ title }}作成中
            .thread-list-item-meta(v-else)
              time.a-meta(datetime='announcement.published_at_date_time')
                span.span.a-meta__label
                  | 公開
                | {{ announcement.published_at }}
          .thread-list-item-meta__item
            .thread-list-item-comment
              .thread-list-item-comment__label
                | コメント
              .thread-list-item-comment__count
                | （{{ announcement.commentsSize }}）
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
      return `is-${this.announcement.user.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.announcement.user.daimyo }
    }
  }
}
</script>
