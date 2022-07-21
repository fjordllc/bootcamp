<template lang="pug">
.card-list-item(:class='{ "is-wip": regularEvent.wip }')
  .card-list-item__inner
    .card-list-item__label(:class='[categoryClass]')
      | {{ regularEvent.category }}
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          .a-list-item-badge.is-wip(v-if='regularEvent.wip')
            span
              | WIP
          .a-list-item-badge.is-ended(v-else-if='regularEvent.finished')
            span
              | 終了
          h2.card-list-item-title__title(itemprop='name')
            a.card-list-item-title__link.a-text-link(
              :href='regularEvent.url',
              itemprop='url'
            )
              | {{ regularEvent.title }}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item(
              v-if='regularEvent.organizers.length > 0'
            )
              .a-meta
                .a-meta__label
                  | 主催
                .a-meta__value
                  .card-list-item__user-icons
                    user-icon(
                      v-for='organizer in regularEvent.organizers',
                      :key='organizer.id',
                      :user='organizer',
                      link_class='card-list-item__user-icons-icon',
                      blockClassSuffix='card-list-item'
                    )
            .card-list-item-meta__item
              time.a-meta(:datetime='regularEvent.start_at')
                span.a-meta__label
                  | 開催日時
                span.a-meta__value
                  | {{ regularEvent.holding_cycles }} {{ regularEvent.start_at_localized }} 〜 {{ regularEvent.end_at_localized }}
            .card-list-item-meta__item(v-if='regularEvent.comments_count > 0')
              .a-meta
                | コメント（{{ regularEvent.comments_count }}）
</template>

<script>
import UserIcon from 'user-icon'

export default {
  components: {
    'user-icon': UserIcon
  },
  props: {
    regularEvent: { type: Object, required: true }
  },
  computed: {
    categoryClass() {
      return `is-${this.regularEvent.category_class}`
    }
  },
}
</script>
