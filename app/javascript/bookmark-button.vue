<template lang="pug">
#bookmark-button.a-bookmark-button.a-button.is-xs.is-block(
  :class='bookmarkId ? "is-active is-main" : "is-inactive is-muted"',
  @click='push'
)
  | {{ bookmarkLabel }}
</template>

<script>
import toast from './toast'

export default {
  mixins: [toast],
  props: {
    bookmarkableId: { type: Number, required: true },
    bookmarkableType: { type: String, required: true },
    checked: { type: Boolean, required: false, default: false },
    bookmarkIndexId: { type: Number, required: false, default: 0 }
  },
  data() {
    return {
      bookmarkId: null,
      bookmarkLabel: 'Bookmark',
      totalPages: 0,
      bookmarkValue: null
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
      if (this.bookmarkId) {
        this.unbookmark()
      } else {
        this.bookmark()
      }
    },
    getBookmark() {
      if (this.checked) {
        this.bookmarkId = this.bookmarkIndexId
        this.bookmarkLabel = '削除'
      } else {
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
              this.bookmarkLabel = 'Bookmark中'
            }
          })
          .catch((error) => {
            console.warn('Failed to parsing', error)
          })
      }
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
          this.bookmarkLabel = 'Bookmark中'
          this.toast('Bookmarkしました！')
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
          this.bookmarkLabel = 'Bookmark'
          this.toast('Bookmarkを削除しました')
        })
        .then(() => {
          this.$emit('update-index')
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>

<style scoped></style>
