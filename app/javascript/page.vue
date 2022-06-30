<template lang="pug">
.card-list-item(:class='page.wip ? "is-wip" : ""')
  .card-list-item__inner
    .card-list-item__user
      a.card-list-item__user-link(:href='page.user.url')
        img.card-list-item__user-icon.a-user-icon(
          :title='page.user.icon_title',
          :alt='page.user.icon_title',
          :src='page.user.avatar_url',
          :class='[roleClassPublishedUser]'
        )

    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          .a-list-item-badge.is-wip(v-if='page.wip')
            span
              | WIP
          h2.card-list-item-title__title(itemprop='name')
            a.card-list-item-title__link.a-text-link(
              :href='page.url',
              itemprop='url'
            )
              | {{ page.title }}

      .card-list-item__row(v-if='page.practice')
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              a.a-meta.is-practice(:href='practiceUrl')
                | {{ page.practice.title }}

      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              .a-meta(v-if='page.wip')
                | Doc作成中
              time.a-meta(
                v-else-if='page.published_at',
                :datetime='page.published_at.to_datetime'
              )
                span.a-meta__label
                  | 公開
                span.a-meta__value
                  | {{ page.published_at }}
            .card-list-item-meta__item(v-if='page.last_updated_user')
              time.a-meta(:datetime='page.updated_at.to_datetime')
                span.a-meta__label
                  | 更新
                span.a-meta__value
                  | {{ page.updated_at }}
            .card-list-item-meta__item(v-if='page.last_updated_user')
              .card-list-item-meta__user
                a.card-list-item-meta__icon-link(
                  :href='page.last_updated_user.url'
                )
                  img.card-list-item-meta__icon.a-user-icon(
                    :title='page.last_updated_user.icon_title',
                    :alt='page.last_updated_user.icon_title',
                    :src='page.last_updated_user.avatar_url',
                    :class='[roleClassLastUpdatedUser]'
                  )
                a.a-user-name(:href='page.last_updated_user.url')
                  | {{ page.last_updated_user.login_name }}
            .card-list-item-meta__item(v-if='page.commentsSize > 0')
              .a-meta
                | コメント（{{ page.commentsSize }}）
</template>
<script>
import UserIcon from 'user-icon.vue'

export default {
  components: {
    userIcon: UserIcon
  },
  props: {
    page: { type: Object, required: true }
  },
  computed: {
    roleClassPublishedUser() {
      return `is-${this.page.user.primary_role}`
    },
    roleClassLastUpdatedUser() {
      return `is-${this.page.last_updated_user.primary_role}`
    },
    practiceUrl() {
      return `/practices/${this.page.practice.id}`
    }
  }
}
</script>
