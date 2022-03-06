<template lang="pug">
.thread-list-item(:class='page.wip ? "is-wip" : ""')
  .thread-list-item__inner
    .thread-list-item__user
      a.a-user-name(:href='page.user.url')
        img.thread-list-item__user-icon.a-user-icon(
          :title='page.user.icon_title',
          :alt='page.user.icon_title',
          :src='page.user.avatar_url',
          :class='[roleClassPublishedUser, daimyoClass]'
        )

    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__icon.is-wip(v-if='page.wip') WIP
          h2.thread-list-item-title__title(itemprop='name')
            a.thread-list-item-title__link(:href='page.url', itemprop='url') {{ page.title }}

      .thread-list-item__row(v-if='page.practice')
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              .thread-list-item-sub-title
                | {{ page.practice.title }}
            .thread-list-item-meta__item(v-if='page.commentsSize > 0')
              .thread-list-item-comment
                .thread-list-item-comment__label
                  | コメント
                .thread-list-item-comment__count
                  | （{{ page.commentsSize }}）

      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              .a-meta(v-if='page.wip')
                | Doc作成中
              time.a-meta(:datetime='page.published_at.to_datetime')(
                v-else-if='page.published_at'
              )
                span.a-meta__label
                  | 公開
                span.a-meta__value
                  | {{ page.published_at }}
            .thread-list-item-meta__item(v-if='page.last_updated_user')
              time.a-meta(:datetime='page.updated_at.to_datetime')
                span.a-meta__label
                  | 更新
                | {{ page.updated_at }} by
                a.thread-list-item-meta__icon-link(:href='page.last_updated_user.url')
                  img.thread-list-item-meta__icon.a-user-icon(
                    :title='page.last_updated_user.icon_title',
                    :alt='page.last_updated_user.icon_title',
                    :src='page.last_updated_user.avatar_url',
                    :class='[roleClassLastUpdatedUser, daimyoClass]'
                  )
                .thread-list-item-name
                  a.a-user-name(:href='page.last_updated_user.url')
                    | {{ page.last_updated_user.login_name }}

      .thread-list-item__row(v-if='page.tags.length > 0')
        .thread-list-item-tags
          .thread-list-item-tags__label
            i.fas.fa-tags
          ul.thread-list-item-tags__items
            li.thread-list-item-tags__item(v-for='tag in page.tags')
              a.thread-list-item-tags__item-link(:href='tag.url') {{ tag.name }}
</template>
<script>
import UserIcon from './user-icon.vue'

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
    daimyoClass() {
      return { 'is-daimyo': this.page.user.daimyo }
    }
  }
}
</script>
