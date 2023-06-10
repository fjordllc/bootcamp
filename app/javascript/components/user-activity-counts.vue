<template lang="pug">
.card-counts.mt-3(v-if='user.student_or_trainee')
  dl.card-counts__items
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label
          | 日報
        dd.card-counts__item-value(
          :class='user.report_count == 0 ? "is-empty" : ""')
          | {{ user.report_count }}
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label
          | 提出物
        dd.card-counts__item-value(
          :class='user.product_count == 0 ? "is-empty" : ""')
          | {{ user.product_count }}
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label
          | コメント
        dd.card-counts__item-value(
          :class='user.comment_count == 0 ? "is-empty" : ""')
          | {{ user.comment_count }}
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label
          | 質問
        dd.card-counts__item-value(
          :class='user.question_count == 0 ? "is-empty" : ""')
          | {{ user.question_count }}
    .card-counts__item
      .card-counts__item-inner
        dt.card-counts__item-label
          | 回答
        dd.card-counts__item-value(
          :class='user.answer_count == 0 ? "is-empty" : ""')
          | {{ user.answer_count }}
</template>
<script>
export default {
  props: {
    user: { type: Object, required: true }
  }
}
</script>
