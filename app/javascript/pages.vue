<template lang="pug">
div
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  div(v-if='pages === null')
    loadingListPlaceholder
  .o-empty-message(v-else-if='pages.length === 0')
    .o-empty-message__icon
      i.far.fa-smile
    p.o-empty-message__text
      | Docはまだありません
  .thread-list.a-card(v-else)
    .thread-list__items
      page(v-for='page in pages', :key='page.id', :page='page')
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
</template>

<script>
import LoadingListPlaceholder from './loading-list-placeholder.vue'
import Pager from './pager.vue'
import page from './page.vue'
export default {
  components: {
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager,
    page: page
  },
  props: {
    selectedTag: { type: String, required: true }
  },
  data() {
    return {
      pages: null,
      currentPage: this.pageParam(),
      totalPages: null
    }
  },
  computed: {
    newParams() {
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      if (this.selectedTag) params.set('tag', this.selectedTag)
      return params
    },
    newURL() {
      return `${location.pathname}?${this.newParams}`
    },
    pagesAPI() {
      const params = this.newParams
      return `/api/pages.json?${params}`
    },
    pagerProps() {
      return {
        initialPageNumber: this.currentPage,
        pageCount: this.totalPages,
        pageRange: 9,
        clickHandle: this.clickCallback
      }
    }
  },
  created() {
    window.onpopstate = () => {
      this.currentPage = this.pageParam()
      this.getPages()
    }
    this.getPages()
  },
  methods: {
    pageParam() {
      const url = new URL(location.href)
      const page = url.searchParams.get('page')
      return parseInt(page || 1)
    },
    clickCallback(pageNum) {
      this.currentPage = pageNum
      history.pushState(null, null, this.newURL)
      this.pages = null
      this.getPages()
      window.scrollTo(0, 0)
    },
    getPages() {
      fetch(this.pagesAPI, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.pages = []
          json.pages.forEach((r) => {
            this.pages.push(r)
          })
          this.totalPages = parseInt(json.totalPages)
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
