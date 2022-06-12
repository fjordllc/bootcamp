<template lang="pug">
.card-list-item(:class='notification.read ? "is-read" : "is-unread"')
  .card-list-item__inner
    .card-list-item__user
      img.card-list-item__user-icon.a-user-icon(
        :title='notification.sender.icon_title',
        :src='notification.sender.avatar_url',
        :class='[roleClass]'
      )
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          .card-list-item-title__start
            .card-list-item-title__icon.is-unread(
              v-if='notification.read === false'
            )
              | 未読
            h2.card-list-item-title__title(itemprop='name')
              a.card-list-item-title__link.a-text-link.js-unconfirmed-link(
                :href='notification.path',
                itemprop='url'
              )
                span.card-list-item-title__link-label
                  | {{ notification.message }}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              time.a-meta(:datetime='notification.created_at')
                | {{ formattedCreatedAtInJapanese }}
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
      return `is-${this.notification.sender.primary_role}`
    }
  }
}
</script>
