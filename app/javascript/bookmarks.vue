<template lang="pug">
.page-body
  .container(v-if='!loaded')
    .empty
      .fas.fa-spinner.fa-pulse
      |
      | ロード中
  .container(v-else-if='bookmarks.length == 0')
    .o-empty-message
      p.o-empty-message__text
      | ブックマークしているものはありません。
  .container(v-else)
    nav.pagenation(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .thread-list.a-card
      .thread-list__items
        bookmark(
          v-for='bookmark in bookmarks',
          :key='bookmark.id',
          :bookmark='bookmark'
        )
    nav.pagenation(v-if='totalPages > 1')
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
          this.totalPages = json.total_pages
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
      if (!results) return null
      return results[1]
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
