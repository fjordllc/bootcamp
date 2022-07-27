<template lang="pug">
.category-practices-item.js-practice
  a.category-practices-item__anchor(:id='`practice_${practices.practice.id}`')
  header.category-practices-item__header
    .category-practices-item__title
      a.category-practices-item__title-link(:href='practices.url')
        | {{ practices.practice.title }}
    a(
      :class='`practice-status category-practices-item__status is-${statusByLearnings(practices.practice.id)}`',
      :href='`${practices.url}#learning-Status`',
      v-if='isCurrentUser'
    )
      | {{ translate(practices.practice.id) }}

  .category-practices-item__learning-time(v-if='practiceTime')
    | <!--- 所要時間の目安: {{ convertToHourMinute(practiceTime.median) }} --->
    | <!--- （平均: {{ convertToHourMinute(practiceTime.average) }}） --->
  .a-user-icons(v-if='practices.started_students.length')
    .a-user-icons__items
      practice-user-icon(
        v-for='startedStudent in practices.started_students',
        :key='startedStudent.id',
        :startedStudent='startedStudent'
      )
</template>

<script>
import PracticeUserIcon from 'practice-user-icon.vue'

export default {
  components: {
    'practice-user-icon': PracticeUserIcon
  },
  props: {
    practices: { type: Object, required: true },
    category: { type: Object, required: true },
    learnings: { type: Array, required: true },
    currentUser: { type: Object, required: true, default: null }
  },
  computed: {
    practiceTime() {
      return this.practices.learning_minute_statistic
    },
    isCurrentUser() {
      return this.currentUser !== null
    }
  },
  methods: {
    statusByLearnings(practices) {
      const learning = this.learnings.find(
        (element) => practices === element.practice_id
      )
      if (!learning) return 'unstarted'
      return learning.status
    },
    convertToHourMinute(time) {
      const hour = parseInt(time / 60)
      const minute = Math.round(time % 60)
      if (minute === 0) {
        return `${hour}時間`
      } else {
        return `${hour}時間${minute}分`
      }
    },
    translate(practices) {
      const learningStatus = this.statusByLearnings(practices)
      return this.toJapanese(learningStatus)
    },
    toJapanese(learningStatus) {
      return {
        unstarted: '未着手',
        started: '着手',
        submitted: '提出',
        complete: '完了'
      }[learningStatus]
    }
  }
}
</script>
