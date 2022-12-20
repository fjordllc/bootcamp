<template lang="pug">
.page-body
  .container.is-md
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .card-list.a-card
      externalEntry(
        v-for='externalEntry in externalEntries',
        :key='externalEntry.id',
        :externalEntry='externalEntry')
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import ExternalEntry from 'components/latest-article.vue'
import Pager from '../pager.vue'

export default {
  name: 'ExternalEntries',
  components: {
    externalEntry: ExternalEntry,
    pager: Pager
  },
  data() {
    return {
      externalEntries: [],
      totalPages: 0,
      currentPage: this.getCurrentPage()
    }
  },
  computed: {
    url() {
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      return `/api/external_entries?${params}`
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
    this.getExternalEntries()
  },
  methods: {
    getExternalEntries() {
      fetch(this.url, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.externalEntries = json.external_entries
          this.totalPages = json.total_pages
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    getCurrentPage() {
      const params = new URLSearchParams(location.search)
      const page = params.get('page')
      return parseInt(page) || 1
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.getExternalEntries()

      const url = new URL(location.href)
      if (pageNumber === 1) {
        url.searchParams.delete('page')
      } else {
        url.searchParams.set('page', pageNumber)
      }
      history.pushState(null, null, url)
      window.scrollTo(0, 0)
    }
  }
}
</script>
