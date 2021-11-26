<template lang="pug">
.thread-list-item(:class='notification.read ? "is-read" : "is-unread"')
  .thread-list-item__inner
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__start
            .thread-list-item-title__icon.is-unread(
              v-if='notification.read === false'
            )
              | 未読
            h2.thread-list-item-title__title(itemprop='name')
              a.thread-list-item-title__link.js-unconfirmed-link(
                :href='notification.path',
                itemprop='url'
              )
                span.thread-list-item-title__link-label {{ notification.message }}
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              time.a-meta(:datetime='notification.created_at') {{ formattedCreatedAtInJapanese }}
    .thread-list-item__user
      img.thread-list-item__user-icon.a-user-icon(
        :title='notification.sender.icon_title',
        :src='notification.sender.avatar_url',
        :class='[roleClass, daimyoClass]'
      )
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)

export default {
  props: {
    notification: { type: Object, required: true }
  },
  computed: {
    formattedCreatedAtInJapanese() {
      return dayjs(this.notification.created_at).format(
        'YYYY年MM月DD日(ddd) HH:mm'
      )
    },
    roleClass() {
      return `is-${this.notification.sender.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.notification.sender.daimyo }
    }
  }
}
</script>
