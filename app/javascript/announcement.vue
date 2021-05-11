<template lang="pug">
.thread-list-item(:class='announcement.wip ? "is-wip" : ""')
  .thread-list-item__inner
    .thread-list-item__author
      a.a-user-name(:href='announcement.user.url')
        img.thread-list-item__author-icon.a-user-icon(
          :title='announcement.user.icon_title',
          :alt='announcement.user.icon_title',
          :src='announcement.user.avatar_url',
          :class='[roleClass, daimyoClass]'
        )
    header.thread-list-item-title
      .thread-list-item-title__icon.is-wip(v-if='announcement.wip') WIP
      h2.thread-list-item-title__title
        a.thread-list-item-title__link(:href='announcement.url')
          | {{ announcement.title }}
      .thread-list-item-actions(
        v-if='currentUser.role == "admin" || currentUser.id == announcement.user.id'
      )
        a.thread-list-item-actions__action(:href='announcement.new_url')
          i.fas.fa-copy
    .thread-list-item-meta(v-if='announcement.wip')
      .a-date
        | {{ title }}作成中
    .thread-list-item-meta(v-else)
      time.a-date(datetime='announcement.published_at_date_time')
        span.span.a-date__label
          | 公開
        | {{ announcement.published_at }}
      .thread-list-item-meta__comment-count
        .thread-list-item-meta__comment-count-label
          i.fas.fa-comment
        .thread-list-item-meta__comment-count-value
          | {{ announcement.commentsSize }}
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
