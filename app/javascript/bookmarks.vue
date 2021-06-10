<template lang="pug">
.page-body
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  .container
    .empty(v-if='!loaded')
      .fas.fa-spinner.fa-pulse
      |
      | ロード中
    .o-empty-message(v-else-if='bookmarks.length == 0')
      p.o-empty-message__text
      | ブックマークしているものはありません。
    .thread-list.a-card(v-else)
      .thread-list__items
        bookmark(
          v-for='bookmark in bookmarks',
          :key='bookmark.id',
          :bookmark='bookmark'
        )
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
</template>
<script>
import Bookmark from './bookmark.vue'
import Pager from './pager.vue'

export default {
  components: {
    bookmark: Bookmark,
    pager: Pager
  },
  data() {
    return {
      bookmarks: [],
      totalPages: 0,
      currentPage: Number(this.getPageValueFromParameter()) || 1,
      loaded: false
    }
  },
  computed: {
    url() {
      return `/api/bookmarks?page=${this.currentPage}`
    },
    pagerProps() {
      return {
        initialPageNumber: this.currentPage,
        pageCount: this.totalPages,
        pageRange: 5,
        clickHandle: this.paginateClickCallback
      }
    }
  },
  created() {
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.getBookmarks()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getBookmarks() {
      fetch(this.url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.totalPages = json.totalPages
          this.bookmarks = []
          json.bookmarks.forEach((bookmark) => {
            this.bookmarks.push(bookmark)
          })
          this.loaded = true
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    getPageValueFromParameter() {
      const url = location.href
      const results = url.match(/\?page=(\d+)/)
      return results ? results[1] : null
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.getBookmarks()
      history.pushState(
        null,
        null,
        location.pathname + (pageNumber === 1 ? '' : `?page=${pageNumber}`)
      )
    }
  }
}
</script>
