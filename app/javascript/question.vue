<template lang="pug">
.thread-list-item(:class='questionClass')
  .thread-list-item__inner
    .thread-list-item__user
      a.a-user-name(:href='question.user.url')
        img.thread-list-item__user-icon.a-user-icon(
          :title='question.user.icon_title',
          :alt='question.user.icon_title',
          :src='question.user.avatar_url',
          :class='[roleClass, daimyoClass]'
        )
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__icon.is-wip(v-if='question.wip')
            | WIP
          h1.thread-list-item-title__title(itemprop='name')
            a.thread-list-item-title__link(
              :href='question.url',
              itemprop='url'
            ) {{ question.title }}
    .thread-list-item__row(v-if='question.practice')
      .thread-list-item-meta
        .thread-list-item-meta__items
          .thread-list-item-meta__item
            .thread-list-item-sub-title {{ question.practice.title }}
    .thread-list-item__row
      .thread-list-item-meta
        .thread-list-item-meta__items
          .thread-list-item-meta__item(v-if='question.wip')
            .a-meta
              | 質問作成中
          .thread-list-item-meta__item
            a.a-user-name(:href='`/users/${question.user.id}`')
              | {{ question.user.long_name }}
    .thread-list-item__row
      .thread-list-item-meta
        .thread-list-item-meta__items
          .thread-list-item-meta__item(v-if='!question.wip')
            time.a-meta
              span.a-meta__label
                | 公開
              span.a-meta__value
                | {{ publishedAt }}
          .thread-list-item-meta__item(v-if='!question.wip')
            time.a-meta
              span.a-meta__label
                | 更新
              span.a-meta__value
                | {{ updatedAt }}
          .thread-list-item-meta__item(v-if='question.answers.size > 0')
            .thread-list-item-comment
              .thread-list-item-comment__label
                | 回答・コメント
              .thread-list-item-comment__count
                | （{{ question.answers.size }}）

    .thread-list-item__row(v-if='question.tags.length > 0')
      .thread-list-item-tags
        .thread-list-item-tags__label
          i.fas.fa-tags
        ul.thread-list-item-tags__items
          li.thread-list-item-tags__item(v-for='tag in question.tags')
            a.thread-list-item-tags__item-link(:href='tag.url') {{ tag.name }}
    .stamp.is-circle.is-solved(v-if='question.has_correct_answer')
      .stamp__content.is-icon 解
      .stamp__content.is-icon 決
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)

export default {
  props: {
    question: { type: Object, required: true }
  },
  computed: {
    updatedAt() {
      return dayjs(this.question.updated_at).format('YYYY年MM月DD日(dd) HH:mm')
    },
    publishedAt() {
      return dayjs(this.question.published_at).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    },
    roleClass() {
      return `is-${this.question.user.primary_role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.question.user.daimyo }
    },
    questionClass() {
      if (this.question.has_correct_answer) {
        return 'is-solved'
      } else if (this.question.wip) {
        return 'is-wip'
      } else {
        return ''
      }
    }
  }
}
</script>
