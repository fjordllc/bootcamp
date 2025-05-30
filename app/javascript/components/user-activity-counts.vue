<template lang="pug">
.card-counts.is-users.mt-3(v-if='user.student_or_trainee')
  dl.card-counts__items
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label 日報
        dd.card-counts__item-value(
          :class='user.report_count == 0 ? "is-empty" : ""')
          span(v-if='user.report_count == 0') {{ user.report_count }}
          a.a-text-link(v-else)(:href='`${user.url}/reports`') {{ user.report_count }}
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label 提出物
        dd.card-counts__item-value(
          :class='user.product_count == 0 ? "is-empty" : ""')
          span(v-if='user.product_count == 0') {{ user.product_count }}
          a.a-text-link(v-else)(:href='`${user.url}/products`') {{ user.product_count }}
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label コメント
        dd.card-counts__item-value(
          :class='user.comment_count == 0 ? "is-empty" : ""')
          span(v-if='user.comment_count == 0') {{ user.comment_count }}
          a.a-text-link(v-else)(:href='`${user.url}/comments`') {{ user.comment_count }}
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label 質問
        dd.card-counts__item-value(
          :class='user.question_count == 0 ? "is-empty" : ""')
          span(v-if='user.question_count == 0') {{ user.question_count }}
          a.a-text-link(v-else)(:href='`${user.url}/questions`') {{ user.question_count }}
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label 回答
        dd.card-counts__item-value(
          :class='user.answer_count == 0 ? "is-empty" : ""')
          span(v-if='user.answer_count == 0') {{ user.answer_count }}
          a.a-text-link(v-else)(:href='`${user.url}/answers`') {{ user.answer_count }}
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label ポートフォリオ
        dd.card-counts__item-value(
          :class='user.work_count == 0 ? "is-empty" : ""')
          span(v-if='user.work_count == 0') {{ user.work_count }}
          a.a-text-link(v-else)(:href='`${user.url}/portfolio`') {{ user.work_count }}
</template>
<script>
export default {
  props: {
    user: { type: Object, required: true }
  }
}
</script>
