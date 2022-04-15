<template lang="pug">
.thread-list-item(:class='announcement.wip ? "is-wip" : ""')
  .thread-list-item__inner
    .thread-list-item__user
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
          .thread-list-item-title__icon.is-wip(v-if='announcement.wip')
            | WIP
          h2.thread-list-item-title__title
            a.thread-list-item-title__link.a-text-link(
              :href='announcement.url'
            )
              | {{ announcement.title }}
      .thread-list-item__row
        a.a-user-name(:href='announcement.user.url')
          | {{ announcement.user.long_name }}
      .thread-list-item__row
        .thread-list-item-meta__items
          .thread-list-item-meta__item
            .a-meta(v-if='announcement.wip')
              | {{ title }}作成中
            time.a-meta(datetime='announcement.published_at_date_time')(v-else)
              span.a-meta__label
                | 公開
              span.a-meta__value
                | {{ announcement.published_at }}
          .thread-list-item-meta__item
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
