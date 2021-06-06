<template lang="pug">
.page-body
  .container
    .thread-list.a-card
      .thread-list__items
        bookmark(
          v-for='bookmark in bookmarks',
          :key='bookmark.id',
          :bookmark='bookmark'
        )
</template>
<script>
import Bookmark from './bookmark.vue'

export default {
  components: {
    bookmark: Bookmark
  },
  data() {
    return {
      bookmarks: null
    }
  },
  created() {
    this.getBookmarks()
  },
  methods: {
    getBookmarks() {
      fetch('/api/bookmarks', {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.bookmarks = []
          json.bookmarks.forEach((bookmark) => {
            this.bookmarks.push(bookmark)
          })
          console.log(this.bookmarks)
          // this.currentUserId = json.currentUserId
          // this.totalPages = parseInt(json.totalPages)
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
