<template lang="pug">
.thread-list.a-card.is-loading
  loadingQuestionPageItemPlaceholder(v-for='num in itemCount', :key='num')
</template>

<script>
import LoadingQuestionPageItemPlaceholder from './loading-question-page-itme-placeholder.vue'

export default {
  components: {
    loadingQuestionPageItemPlaceholder: LoadingQuestionPageItemPlaceholder
  },
  data() {
    return {
      itemCount: 8
    }
  }
}
</script>
