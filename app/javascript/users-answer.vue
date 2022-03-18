<template lang="pug">
.thread-list-item(:class='answer.question.correct_answer ? "is-solved" : ""')
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
              a.a-user-name {{ answer.question.user.long_name }}
            .thread-list-item-meta__item
              time.a-meta(:datetime='answer.question.updated_at.datetime') {{ answer.question.updated_at.locale }}
      .answer-badge(v-if='answer.type == "CorrectAnswer"')
        .answer-badge__icon
          i.fas.fa-star
        .answer-badge__label ベストアンサー
</template>
<script>
export default {
  props: {
    answer: { type: Object, required: true }
  },
  computed: {
    roleClass() {
      return `is-${this.answer.question.user.primary_role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.answer.question.user.daimyo }
    }
  }
}
</script>
