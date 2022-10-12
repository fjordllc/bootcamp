<template lang="pug">
.page-body
  .container.is-md
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .card-list.a-card
      latestArticle(
        v-for='latestArticle in latestArticles',
        :key='latestArticle.id',
        :latestArticle='latestArticle'
      )
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import LatestArticle from './latest-article'
import Pager from '../pager.vue'

export default {
  name: 'LatestArticles',
  components: {
    latestArticle: LatestArticle,
    pager: Pager
  },
  data() {
    return {
      latestArticles: [],
      totalPages: 0,
      currentPage: this.getCurrentPage()
    }
  },
  computed: {
    url() {
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      return `/api/latest_articles?${params}`
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
    this.getLatestArticles()
  },
  methods: {
    getLatestArticles() {
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
          this.latestArticles = json.latest_articles
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
      this.getLatestArticles()

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
