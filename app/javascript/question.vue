<template lang="pug">
.thread-list-item(:class='question.has_correct_answer ? "is-solved" : ""')
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
          .thread-list-item-meta__item
            a.a-user-name {{ question.user.long_name }}
          .thread-list-item-meta__item
            time.a-meta(
              :datetime='question.updated_at.datetime',
              pubdate='pubdate'
            ) {{ question.updated_at.locale }}

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
export default {
  props: {
    question: { type: Object, required: true }
  },
  computed: {
    roleClass() {
      return `is-${this.question.user.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.question.user.daimyo }
    }
  }
}
</script>
