<template lang="pug">
.card-list-item(:class='{ "is-wip": event.wip }')
  .card-list-item__inner
    .card-list-item__user
      user-icon(
        :user='event.user',
        link_class='card-list-item__user-link',
        blockClassSuffix='card-list-item'
      )
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          .card-list-item-title__icon.is-wip(v-if='event.wip') WIP
          .card-list-item-title__icon.is-ended(v-else-if='event.ended') 終了
          h2.card-list-item-title__title(itemprop='name')
            a.card-list-item-title__link.a-text-link(
              :href='event.url',
              itemprop='url'
            )
              | {{ event.title }}
      .card-list-item__row
        a.a-user-name(:href='event.user.url')
          | {{ event.user.long_name }}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              time.a-meta(:datetime='event.start_at')
                span.a-meta__label
                  | 開催日時
                span.a-meta__value
                  | {{ event.start_at_localized }}
            .card-list-item-meta__item
              .a-meta
                | 参加者（{{ event.participants_count }}名 / {{ event.capacity }}名）
            .card-list-item-meta__item(v-if='event.waitlist_count > 0')
              .a-meta
                | 補欠者（{{ event.waitlist_count }}名）
            .card-list-item-meta__item(v-if='event.comments_count > 0')
              .a-meta
                | コメント（{{ event.comments_count }}）
</template>

<script>
import UserIcon from 'user-icon'

export default {
  components: {
    'user-icon': UserIcon
  },
  props: {
    event: { type: Object, required: true }
  }
}
</script>
