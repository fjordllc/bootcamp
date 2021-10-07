<template lang="pug">
.page-body
  .container(v-if='!loaded')
    | ロード中
  .container.is-md(v-else)
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .thread-list.a-card
      worriedUsers(v-for='worriedUser in worriedUsers', :key='worriedUser.id', :worriedUser='worriedUser')
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import WorriedUsers from './worried-user.vue'
import Pager from './pager.vue'

export default {
  components: {
    worriedUsers: WorriedUsers,
    pager: Pager
  },
  data() {
    return {
      worriedUsers: [],
      totalPages: 0,
      currentPage: this.getCurrentPage(),
      loaded: false
    }
  },
  computed: {
    url() {
      return `/api/mentor?page=${this.currentPage}`
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
    window.onpopstate = () => {
      this.currentPage = this.getCurrentPage()
      this.getMentorsPerPage()
    }
    this.getMentorsPerPage()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getMentorsPerPage() {
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
        .then((response) => response.json())
        .then((json) => {
          this.worriedUsers = json.worried_users
          this.totalPages = json.total_pages
          this.loaded = true
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    getCurrentPage() {
      const params = new URLSearchParams(location.search)
      const page = params.get('page')
      return parseInt(page) || 1
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.getMentorsPerPage()

      const url = new URL(location.href)
      if (pageNumber === 1) {
        url.searchParams.delete('page')
      } else {
        url.searchParams.set('page', pageNumber)
      }
      history.pushState(history.state, '', url)
    }
  }
}
</script>
