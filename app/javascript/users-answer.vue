<template lang="pug">
.card-list-item(:class='answerClass')
  .card-list-item__inner
    .card-list-item__user
      a.card-list-item__user-link(:href='answer.question.user.url')
        img.card-list-item__user-icon.a-user-icon(
          :title='answer.question.user.icon_title',
          :alt='answer.question.user.icon_title',
          :src='answer.question.user.avatar_url',
          :class='[roleClass]'
        )
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          h1.card-list-item-title__title(itemprop='name')
            a.card-list-item-title__link.a-text-link(
              :href='answer.question.url',
              itemprop='url'
            ) {{ answer.question.title }}
      .card-list-item__row(v-if='answer.question.practice')
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              a.a-meta.is-practice(
                :href='`/practices/${answer.question.practice.id}`'
              ) {{ answer.question.practice.title }}
      .card-list-item__row
        .card-list-item__summary
          p {{ summary }}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              a.a-user-name(:href='`/users/${answer.question.user.id}`')
                | {{ answer.question.user.long_name }}
            .card-list-item-meta__item
              time.a-meta(:datetime='answer.updated_at', pubdate='pubdate') {{ updatedAt }}
      .answer-badge(v-if='answer.type == "CorrectAnswer"')
        .answer-badge__icon
          i.fa-solid.fa-star
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
      return dayjs(this.answer.updated_at).format('YYYY年MM月DD日(dd) HH:mm')
    },
    roleClass() {
      return `is-${this.answer.question.user.primary_role}`
    },
    answerClass() {
      if (this.answer.has_correct_answer) {
        return 'is-solved'
      } else {
        return ''
      }
    },
    summary() {
      let description = this.answer.description
      description =
        description.length <= 90
          ? description
          : description.substring(0, 90) + '...'
      return description
    }
  }
}
</script>
