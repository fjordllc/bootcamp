<template lang="pug">
.thread-list.a-card.is-loading
  loadingListItemPlaceholder(v-for='num in itemCount', :key='num')
</template>

<script>
import LoadingListItemPlaceholder from './loading-list-item-placeholder.vue'

export default {
  components: {
    loadingListItemPlaceholder: LoadingListItemPlaceholder
  },
  data() {
    return {
      itemCount: 8
    }
  }
}
</script>
