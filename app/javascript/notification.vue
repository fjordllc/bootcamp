<template lang="pug">
  .thread-list-item(:class="notification.read ? 'is-read' : 'is-unread'")
    .thread-list-item__inner
      .thread-list-item__author
        img.thread-list-item__author-icon.a-user-icon(:title="notification.sender.icon_title" :src="notification.sender.avatar_url" :class="[roleClass, daimyoClass]")
      header.thread-list-item__header
        .thread-list-item__header-title-container
          .thread-list-item__header-icon.is-unread(v-if='notification.read === false')
            | 未読
          h2.thread-list-item__title(itemprop='name')
            a.thread-list-item__title-link.js-unconfirmed-link(:href="notification.path" itemprop='url')
              span.thread-list-item__title-link-label {{ notification.message }}
      .thread-list-item-meta
        time.thread-list-item-meta__created-at(:datetime='notification.created_at') {{ notification.created_at }}
</template>
<script>
export default {
  props: ['notification'],
  computed: {
    roleClass() {
      return `is-${this.notification.sender.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.notification.sender.daimyo }
    }
  }
}
</script>
