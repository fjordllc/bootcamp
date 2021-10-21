<template lang="pug">
.thread-list-item(:class='wipClass')
  .thread-list-item__inner
    template(v-if='currentUserId == report.user.id')
      label.thread-list-item-actions__trigger(:for='report.id')
        i.fas.fa-ellipsis-h
    .thread-list-item__rows
      .thread-list-item__row
        header.thread-list-item-title
          .thread-list-item-title__start
            .thread-list-item-title__icon.is-wip(v-if='report.wip') WIP
            h2.thread-list-item-title__title
              a.thread-list-item-title__link.js-unconfirmed-link(
                :href='report.url'
              ) {{ report.user.daimyo ? "★" + report.title : report.title }}

          .thread-list-item-title__end
            .thread-list-item-actions(v-if='currentUserId == report.user.id')
              input.a-toggle-checkbox(type='checkbox', :id='report.id')
              .thread-list-item-actions__inner
                ul.thread-list-item-actions__items
                  li.thread-list-item-actions__item
                    a.thread-list-item-actions__action(:href='report.editURL')
                      i.fas.fa-pen
                      | 内容変更
                  li.thread-list-item-actions__item
                    a.thread-list-item-actions__action(:href='report.newURL')
                      i.fas.fa-copy
                      | コピー
                label.a-overlay(:for='report.id')

      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              a.a-user-name(:href='report.user.url') {{ report.user.login_name }}
            .thread-list-item-meta__item
              time.a-meta {{ report.reportedOn }}
                | の日報
      hr.thread-list-item__row-separator
      .thread-list-item__row(v-if='report.hasAnyComments')
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              .thread-list-item-comment
                .thread-list-item-comment__label
                  | コメント
                .thread-list-item-comment__count
                  | ({{ report.numberOfComments }})
                .thread-list-item-comment__user-icons
                  comment-user-icon(
                    v-for='comment in report.comments',
                    :key='comment.id',
                    :comment='comment'
                  )
                time.a-meta(
                  datetime='report.lastCommentDatetime',
                  pubdate='\'pubdate\''
                )
                  | 〜 {{ report.lastCommentDate }}
    .stamp.stamp-approve(v-if='this.report.hasCheck')
      h2.stamp__content.is-title 確認済
      time.stamp__content.is-created-at {{ report.checkDate }}
      .stamp__content.is-user-name {{ report.checkUserName }}
    .thread-list-item__author
      a.thread-header__author-link(:href='report.user.url')
        img.thread-list-item__author-icon.a-user-icon(
          :src='report.user.avatar_url',
          :title='report.user.login_name',
          :alt='report.user.login_name',
          :class='[roleClass, daimyoClass]'
        )
</template>

<script>
import CommentUserIcon from './comment-user-icon.vue'

export default {
  components: {
    'comment-user-icon': CommentUserIcon
  },
  props: {
    report: { type: Object, required: true },
    // issue #2625 を修正すれば、required: true にし、defaultはいらなくなる
    currentUserId: { type: Number, required: false, default: null }
  },
  computed: {
    roleClass() {
      return `is-${this.report.user.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.report.user.daimyo }
    },
    wipClass() {
      return { 'is-wip': this.report.wip }
    }
  }
}
</script>
