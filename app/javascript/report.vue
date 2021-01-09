<template lang="pug">
  .thread-list-item
    .thread-list-item__inner
      .thread-list-item__author
        a.thread-header__author(:href="report.user.url")
          img.thread-list-item__author-icon.a-user-icon(:src="report.user.avatar_url" :title="report.user.login_name" :alt="report.user.login_name" :class="[roleClass, daimyoClass]")
      header.thread-list-item__header
        .thread-list-item__header-title-container
          .thread-list-item__header-icon.is-wip(v-if="report.wip") WIP
          h2.thread-list-item__title(itemprop='name')
            a.thread-list-item__title-link.js-unconfirmed-link(:href="report.url") {{ report.user.daimyo ? '★' + report.title : report.title }}
          .thread-list-item__actions(v-if="currentUserId == report.user.id")
            a.thread-list-item__actions-link(:href="report.editURL")
              i.fas.fa-pen
            a.thread-list-item__actions-link(:href="report.newURL")
              i.fas.fa-copy
      .thread-list-item-meta(v-if="report.hasAnyComments")
        .thread-list-item-meta__label
          | コメント
        .thread-list-item-meta__comment-count
          .thread-list-item-meta__comment-count-value
            | {{ report.numberOfcomments }}
        .thread-list-item__user-icons
          comment-user-icon(v-for="(comment, index) in report.comments" :key="comment.id" :comment="comment")
        time.thread-list-item-meta__datetime(datetime="report.lastCommentDatetime" pubdate="'pubdate'")
          | 〜 {{ report.lastCommentDate }}
      .thread-list-item-meta
        a.link_to.thread-header__author(:href="report.user.url") {{ report.user.login_name }}
        time.thread-list-item-meta__datetime {{ report.reportedOn }}
          | の日報
      .stamp.stamp-approve(v-if="this.report.hasCheck")
        h2.stamp__content.is-title 確認済
        time.stamp__content.is-created-at {{ report.checkDate }}
        .stamp__content.is-user-name {{ report.checkUserName }}
</template>

<script>
import CommentUserIcon from './comment-user-icon.vue'

export default {
  components: {
    "comment-user-icon": CommentUserIcon
  },
  props: ['report', 'currentUserId'],
  computed: {
    roleClass() {
      return `is-${this.report.user.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.report.user.daimyo }
    },
  },
}
</script>
