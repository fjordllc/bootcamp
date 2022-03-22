<template lang="pug">
.thread-list-item(:class='answerClass')
  .thread-list-item__inner
    .thread-list-item__user
      a.a-user-name(:href='answer.question.user.url')
        img.thread-list-item__user-icon.a-user-icon(
          :title='answer.question.user.icon_title',
          :alt='answer.question.user.icon_title',
          :src='answer.question.user.avatar_url',
          :class='[roleClass, daimyoClass]'
        )
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          h1.thread-list-item-title__title(itemprop='name')
            a.thread-list-item-title__link(
              :href='answer.question.url',
              itemprop='url'
            ) {{ answer.question.title }}
      .thread-list-item__row(v-if='answer.question.practice')
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              .thread-list-item-sub-title {{ answer.question.practice.title }}
      .thread-list-item__row
        .thread-list-item__summary
          p {{ answer.description }}
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              a.a-user-name(:href='`/users/${answer.question.user.id}`')
               | {{ answer.question.user.long_name }}
            .thread-list-item-meta__item
              time.a-meta(:datetime='answerCreatedAt', pubdate='pubdate') {{ updatedAt }}
      .answer-badge(v-if='answer.type == "CorrectAnswer"')
        .answer-badge__icon
          i.fas.fa-star
        .answer-badge__label ベストアンサー
</template>
<script>
import dayjs from 'dayjs'

export default {
  props: {
    answer: { type: Object, required: true }
  },
  computed: {
    updatedAt() {
      return dayjs(this.answer.question.updated_at).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    },
    answerCreatedAt: function () {
      return dayjs(this.answer.question.created_at).format()
    },
    roleClass() {
      return `is-${this.answer.question.user.primary_role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.answer.question.user.daimyo }
    },
    answerClass() {
      if (this.answer.has_correct_answer) {
        return 'is-solved'
      } else {
        return ''
      }
    }
  }
}
</script>
