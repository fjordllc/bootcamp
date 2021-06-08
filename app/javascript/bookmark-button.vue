<template lang="pug">
.thread-header-actions__action
  .a-button.is-xs(
    :class='isBookmark ? "is-secondary" : "is-main"',
    @click='push'
  )
    | {{ bookmarkLabel }}
</template>
<script>
export default {
  props: {
    bookmarkableId: { type: Number, required: true },
    bookmarkableType: { type: String, required: true }
  },
  data() {
    return {
      bookmarkId: null,
      bookmarkLabel: 'bookmark',
      isBookmark: false
    }
  },
  created() {
    this.getBookmark()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    push() {
      if (this.isBookmark) {
        this.unbookmark()
      } else {
        this.bookmark()
      }
    },
    getBookmark() {
      fetch(
        `/api/bookmarks.json?bookmarkable_type=${this.bookmarkableType}&bookmarkable_id=${this.bookmarkableId}`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual'
        }
      )
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          if (json.bookmarks.length) {
            this.bookmarkId = json.bookmarks[0].id
            this.bookmarkLabel = 'unbookmark'
            this.isBookmark = true
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    bookmark() {
      fetch(
        `/api/bookmarks.json?bookmarkable_type=${this.bookmarkableType}&bookmarkable_id=${this.bookmarkableId}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual'
        }
      )
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.bookmarkId = json.id
          this.bookmarkLabel = 'unbookmark'
          this.isBookmark = true
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    unbookmark() {
      fetch(`/api/bookmarks/${this.bookmarkId}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(() => {
          this.bookmarkId = null
          this.bookmarkLabel = 'bookmark'
          this.isBookmark = false
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
