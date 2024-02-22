<template lang="pug">
.card-counts.is-users.mt-3(v-if='user.student_or_trainee')
  dl.card-counts__items
    user-activity-count(
      activity-name='日報',
      :activity-count='user.report_count',
      :activity-url='`${user.url}/reports`')
    user-activity-count(
      activity-name='提出物',
      :activity-count='user.product_count',
      :activity-url='`${user.url}/products`')
    user-activity-count(
      activity-name='コメント',
      :activity-count='user.comment_count',
      :activity-url='`${user.url}/comments`')
    user-activity-count(
      activity-name='質問',
      :activity-count='user.question_count',
      :activity-url='`${user.url}/questions`')
    user-activity-count(
      activity-name='回答',
      :activity-count='user.answer_count',
      :activity-url='`${user.url}/answers`')
</template>
<script>
import UserActivityCount from './user-activity-count.vue'
export default {
  components: {
    'user-activity-count': UserActivityCount
  },
  props: {
    user: { type: Object, required: true }
  }
}
</script>
