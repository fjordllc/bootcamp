<template lang="pug">
.card-list-item
  .card-list-item__inner
    .card-list-item__user
      user-icon(
        :user='user',
        link_class='card-list-item__user-link',
        blockClassSuffix='card-list-item'
      )
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          h2.card-list-item-title__title(itemprop='name')
            a.card-list-item-title__link.a-text-link(
              :href='`/talks/${talk.id}#latest-comment`',
              itemprop='url'
            )
              | {{ user.long_name }} さんの相談部屋
      hr.card-list-item__row-separator(v-if='talk.has_any_comments')
      .card-list-item__row(v-if='talk.has_any_comments')
        .card-list-item-meta__items
          .card-list-item-meta__item
            .card-list-item-meta
              .card-list-item-meta__items
                .card-list-item-meta__item
                  .a-meta
                    | コメント（{{ talk.number_of_comments }}）
                .card-list-item-meta__item
                  .card-list-item__user-icons
                    .card-list-item__user-icon
                      img.a-user-icon(:src='talk.last_comment_user_icon')
                .card-list-item-meta__item
                  .a-meta
                    | 〜 {{ talk.last_commented_at }}
                .card-list-item-meta__item
                  .a-meta(v-if='talk.last_comment_user.admin')
                    | （管理者）
                  .a-meta(v-else)
                    | （{{ user.login_name }}）
</template>
<script>
import UserIcon from 'user-icon'
export default {
  components: {
    'user-icon': UserIcon
  },
  props: {
    user: { type: Object, required: true },
    talk: { type: Object, required: true }
  }
}
</script>
