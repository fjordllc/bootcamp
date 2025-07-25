<template lang="pug">
.card-list-item(:class='questionClass')
  .card-list-item__inner
    .card-list-item__user
      a.card-list-item__user-link(:href='question.user.url')
        span(:class='["a-user-role", roleClass, joiningStatusClass]')
          img.card-list-item__user-icon.a-user-icon(
            :title='question.user.icon_title',
            :alt='question.user.icon_title',
            :src='question.user.avatar_url')
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          .a-list-item-badge.is-wip(v-if='question.wip')
            span
              | WIP
          h1.card-list-item-title__title(itemprop='name')
            a.card-list-item-title__link.a-text-link(
              :href='question.url',
              itemprop='url') {{ question.title }}

      .card-list-item__row(v-if='question.practice')
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              a.a-meta.is-practice(
                :href='practiceUrl',
                v-if='practiceUrl !== null')
                | {{ question.practice.title }}

      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item(v-if='question.wip')
              .a-meta
                | 質問作成中
            .card-list-item-meta__item
              a.a-user-name(:href='`/users/${question.user.id}`')
                | {{ question.user.long_name }}

      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item(v-if='!question.wip')
              time.a-meta
                span.a-meta__label
                  | 公開
                span.a-meta__value
                  | {{ publishedAt }}
            .card-list-item-meta__item(v-if='!question.wip')
              time.a-meta
                span.a-meta__label
                  | 更新
                span.a-meta__value
                  | {{ updatedAt }}
            .card-list-item-meta__item
              .a-meta(:class='[urgentClass]')
                | 回答・コメント（{{ question.answers.size }}）
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
    hasAnswers() {
      return this.question.answers.size > 0
    },
    roleClass() {
      return `is-${this.question.user.primary_role}`
    },
    joiningStatusClass() {
      return this.question.user.joining_status === 'new-user'
        ? 'is-new-user'
        : ''
    },
    urgentClass() {
      return {
        'is-important': !this.hasAnswers
      }
    },
    questionClass() {
      if (this.question.has_correct_answer) {
        return 'is-solved'
      } else if (this.question.wip) {
        return 'is-wip'
      } else {
        return ''
      }
    },
    practiceUrl() {
      return this.question.practice === undefined
        ? null
        : `/practices/${this.question.practice.id}`
    }
  }
}
</script>
