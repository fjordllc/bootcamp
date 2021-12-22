<template lang="pug">
.thread-list-item(:class='page.wip ? "is-wip" : ""')
  .thread-list-item__inner
    .thread-list-item__user
      a.a-user-name(:href='page.user.url')
        img.thread-list-item__user-icon.a-user-icon(
          :title='page.user.icon_title',
          :alt='page.user.icon_title',
          :src='page.user.avatar_url',
          :class='[roleClass, daimyoClass]'
        )
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__icon.is-wip(v-if='page.wip')
            | WIP
          h2.thread-list-item-title__title
            a.thread-list-item-title__link(:href='page.url')
              | {{ page.title }}
      .thread-list-item__row(v-if='page.practice')
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              .thread-list-item-sub-title
                | {{ page.practice.title }}
            .thread-list-item-meta__item
              .thread-list-item-comment
                .thread-list-item-comment__label
                  | コメント
                .thread-list-item-comment__count
                  | （{{ page.commentsSize }}）
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              .thread-list-item-meta(v-if='page.wip')
                .a-meta
                  | 作成中
              .thread-list-item-meta(v-else)
                time.a-meta(datetime='page.published_at_date_time')
                  span.span.a-meta__label
                    | 公開
                  | {{ page.published_at }}
            .thread-list-item-meta__item
              .thread-list-item-meta
                time.a-meta(datetime='page.updated_at_date_time')
                  span.span.a-meta__label
                    | 更新
                  | {{ page.updated_at }} by
                  a.thread-list-item-meta__icon-link(:href='page.user.url')
                    img.thread-list-item__user-icon.a-user-icon(
                      :title='page.user.icon_title',
                      :alt='page.user.icon_title',
                      :src='page.user.avatar_url',
                      :class='[roleClass, daimyoClass]'
                    )
                  a.a-user-name(:href='page.user.url')
                  | {{page.user.login_name }}
      .thread-list-item__row(v-if='page.tags.length > 0')
        .thread-list-item-tags
          .thread-list-item-tags__label
            i.fas.fa-tags
          ul.thread-list-item-tags__items
            li.thread-list-item-tags__item(v-for='tag in page.tags')
              a.thread-list-item-tags__item-link(:href='tag.url') {{ tag.name }}
</template>

<script>
export default {
  props: {
    page: { type: Object, required: true }
  },
  computed: {
    roleClass() {
      return `is-${this.page.user.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.page.user.daimyo }
    }
  }
}
</script>
