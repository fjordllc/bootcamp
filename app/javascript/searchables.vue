<template lang="pug">
.page-body
  .container(v-if='!loaded')
    | ロード中
  .container(v-else-if='searchables.length === 0')
    .o-empty-message
      .o-empty-message__icon
        i.far.fa-sad-tear
      p.o-empty-message__text
        | '{{ word }}'に一致する情報は見つかりませんでした。
  .container.is-md(v-else)
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .thread-list.a-card
      searchable(
        v-for='searchable in searchables',
        :key='searchable.id',
        :searchable='searchable',
        :word='word'
      )
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import Searchable from './searchable.vue'
import Pager from './pager.vue'
export default {
  components: {
    searchable: Searchable,
    pager: Pager
  },
  props: {
    documentType: { type: String, required: true },
    word: { type: String, required: true }
  },
  data() {
    return {
      searchables: [],
      totalPages: 0,
      currentPage: Number(this.getPageValueFromParameter()) || 1,
      loaded: false
    }
  },
  computed: {
    url() {
      return `/api/searchables?document_type=${this.documentType}&page=${this.currentPage}&word=${this.word}`
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
    this.getSearchablesPerPage()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getSearchablesPerPage() {
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
          this.searchables = []
          json.searchables.forEach((searchable) => {
            this.searchables.push(searchable)
          })
          this.loaded = true
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    getPageValueFromParameter() {
      const url = location.href
      const results = url.match(/page=(\d+)/)
      if (!results) return null
      return results[1]
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.getSearchablesPerPage()
      history.pushState(
        null,
        null,
        location.pathname +
          `?document_type=${this.documentType}` +
          (pageNumber === 1 ? '' : `&page=${pageNumber}`) +
          `&word=${this.word}`
      )
    }
  }
}
</script>
