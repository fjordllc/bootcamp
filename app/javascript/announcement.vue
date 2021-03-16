<template lang="pug">
  .thread-list-item(:class="announcement.wip ? 'is-wip' : ''")
    .thread-list-item__inner
      .thread-list-item__author
        a.thread-header__author(:href="announcement.user.url")
          img.thread-list-item__author-icon.a-user-icon(
            :title="announcement.user.icon_title"
            :alt="announcement.user.icon_title"
            :src="announcement.user.avatar_url"
            :class="[roleClass, daimyoClass]")
      header.thread-list-item__header
        .thread-list-item__header-icon.is-wip(v-if="announcement.wip") WIP
        h2.thread-list-item__title
          a.thread-list-item__title-link(:href="announcement.url")
            | {{ announcement.title }}
        .thread-list-item__actions(v-if="currentUser.role == 'admin' || currentUser.id == announcement.user.id")
          a.thread-list-item__actions-link(:href="announcement.newURL")
            i.fas.fa-copy
      .thread-list-item-meta(v-if="announcement.wip")
        .thread-list-item-meta__datetime
          | {{ title }}作成中
      .thread-list-item-meta(v-else)
        time.thread-list-item-meta__datetime(datetime="announcement.published_at_date_time")
          span.span.thread-list-item-meta__datetime-label
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
  props: ['title', 'announcement', 'currentUser'],
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
