<template lang="pug">
.thread-list.a-card.is-loading
  loadingListItem(v-for='num in itemCount', :key='num')
</template>

<script>
import LoadingListItem from './loading-list-item.vue'

export default {
  components: {
    loadingListItem: LoadingListItem
  },
  data() {
    return {
      itemCount: 8
    }
  }
}
</script>
