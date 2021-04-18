<template lang="pug">
  .category-practices-item.js-practice
    a.category-practices-item__anchor(:id="`practice_${category.id}`")
    header.category-practices-item__header
      .category-practices-item__title
        a.category-practices-item__title-link(:href="practices.url")
          | {{practices.practice.title}}
      //if current_userユーザーの進捗パネル表示
      a(:class="`practice-status category-practices-item__status is-${statusByLearnings(practices.practice.id)}`" :href="`${practices.url}#learning-Status`")
        | {{japnaeseStatus(practices.practice.id)}}
    .category-practices-item__learning-time(v-if="practiceTime")
      | 所要時間の目安: {{practiceTime.median}}
      | （平均: {{convertToHourMinute(practiceTime.average)}})
    .m-user-icons(v-if="practices.started_students.length")
      .m-user-icons__items
        practice-user-icon(
          v-for="startedStudent in practices.started_students"
          :key = "startedStudent.id"
          :startedStudent="startedStudent")
        //ここからユーザーアイコンを取得。
</template>


<script>
import PracticeUserIcon from './practice-user-icon.vue'

export default {
  props: ['courseId','currentUserId','category','learnings','practices'],
  components: {
    'practice-user-icon': PracticeUserIcon
  },
  data: () => {
    return {
      currentPage: 1,
      totalPages: null,
      learningStatus: ["未着手","着手","提出","完了"]
    }
  },
  methods: {
    statusByLearnings(practices){
      let le = this.learnings.find(element => practices === element.practice_id)
      if(!le) return 'unstarted'
      return le.status
    },
    convertToHourMinute(time){
      let hour = parseInt(time / 60)
      let minute = Math.round(time % 60)
      if(minute === 0){
        return `${hour}時間`
      }else{
        return `${hour}時間${minute}分`
      }
    },
    japnaeseStatus(practices){
      let status = this.statusByLearnings(practices)
      switch(status){
        case 'unstarted':
          return this.learningStatus[0]
          break
        case 'started':
          return this.learningStatus[1]
          break
        case 'submitted':
          return this.learningStatus[2]
          break
        case 'complete':
          return this.learningStatus[3]
          break
      }
    }
  },
  computed: {
    practiceTime() {
       return this.practices.learning_minute_statistic
    }
  },
}

</script>
