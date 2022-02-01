<template lang="pug">
.thread-list.a-card.is-loading
  loadingListQuestionPagePlaceholder(v-for='num in itemCount', :key='num')
</template>

<script>
import LoadingListQuestionPageItemPlaceholder from './loading-question-page-itme-placeholder.vue'

export default {
  components: {
    loadingListQuestionPageItemPlaceholder: LoadingListQuestionPageItemPlaceholder
  },
  data() {
    return {
      itemCount: 8
    }
  }
}
</script>
