<template lang="pug">
.card-list-item(:class='wipClass')
  .card-list-item__inner
    .card-list-item__user(v-if='userIcon')
      a.card-list-item__user-link(:href='report.user.url')
        img.card-list-item__user-icon.a-user-icon(
          :src='report.user.avatar_url',
          :title='report.user.login_name',
          :alt='report.user.login_name',
          :class='[roleClass]'
        )
    .card-list-item__rows
      .card-list-item__row
        header.card-list-item-title
          .card-list-item-title__start
            .a-list-item-badge.is-wip(v-if='report.wip')
              span
                | WIP
            h2.card-list-item-title__title
              a.card-list-item-title__link.a-text-link.js-unconfirmed-link(
                :href='report.url'
              )
                img.card-list-item-title__emotion-image(
                  :src='emotionImg',
                  :alt='report.emotion'
                )
                | {{ report.title }}
            .card-list-item-title__end(v-if='currentUserId == report.user.id')
              label.card-list-item-actions__trigger(:for='report.id')
                i.fa-solid.fa-ellipsis-h
              .card-list-item-actions
                input.a-toggle-checkbox(type='checkbox', :id='report.id')
                .card-list-item-actions__inner
                  ul.card-list-item-actions__items
                    li.card-list-item-actions__item
                      a.card-list-item-actions__action(:href='report.editURL')
                        i.fa-solid.fa-pen
                        | 内容変更
                    li.card-list-item-actions__item
                      a.card-list-item-actions__action(:href='report.newURL')
                        i.fa-solid.fa-copy
                        | コピー
                  label.a-overlay(:for='report.id')

      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              a.a-user-name(:href='report.user.url') {{ report.user.long_name }}
            .card-list-item-meta__item
              time.a-meta
                | {{ report.reportedOn }}の日報
      hr.card-list-item__row-separator(v-if='report.hasAnyComments')
      .card-list-item__row(v-if='report.hasAnyComments')
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              .a-meta
                | コメント（{{ report.numberOfComments }}）
            .card-list-item-meta__item
              .card-list-item__user-icons
                comment-user-icon(
                  v-for='comment in report.comments',
                  :key='comment.id',
                  :comment='comment'
                )
            .card-list-item-meta__item
              time.a-meta(
                datetime='report.lastCommentDatetime',
                pubdate='\'pubdate\''
              )
                | 〜 {{ report.lastCommentDate }}
    .stamp.stamp-approve(v-if='this.report.hasCheck')
      h2.stamp__content.is-title
        | 確認済
      time.stamp__content.is-created-at
        | {{ report.checkDate }}
      .stamp__content.is-user-name
        .stamp__content-inner
          | {{ report.checkUserName }}
</template>

<script>
import CommentUserIcon from 'comment-user-icon.vue'

export default {
  components: {
    'comment-user-icon': CommentUserIcon
  },
  props: {
    report: { type: Object, required: true },
    currentUserId: { type: Number, required: true },
    userIcon: { type: Boolean }
  },
  computed: {
    roleClass() {
      return `is-${this.report.user.primary_role}`
    },
    wipClass() {
      return { 'is-wip': this.report.wip }
    },
    emotionImg() {
      return `/images/emotion/${this.report.emotion}.svg`
    }
  }
}
</script>
