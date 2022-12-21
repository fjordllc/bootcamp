<template lang="pug">
.page-body
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  .container.is-lg(v-if='generations.length == 0 && loaded')
    .o-empty-message
      .o-empty-message__icon
        i.fa-regular.fa-smile
      p.o-empty-message__text
        | ユーザーはありません
  .container.is-lg(v-else)
    .card-list.a-card
      generation(
        v-for='generation in generations',
        :key='generation.number',
        :generation='generation',
        :target='target')
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
</template>
<script>
import Generation from './generation.vue'
import Pager from './pager.vue'

export default {
  components: {
    generation: Generation,
    pager: Pager
  },
  props: {
    target: {
      type: String,
      required: false,
      default: 'all'
    }
  },
  data() {
    return {
      generations: [],
      loaded: false,
      currentPage: this.getCurrentPage(),
      totalPages: 0
    }
  },
  computed: {
    pagerProps() {
      return {
        initialPageNumber: this.currentPage,
        pageCount: this.totalPages,
        pageRange: 5,
        clickHandle: this.paginateClickCallback
      }
    },
    api_url() {
      return `/api/generations.json?page=${this.currentPage}&target=${this.target}`
    }
  },
  created() {
    this.getGenerations()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getGenerations() {
      this.loaded = false
      fetch(this.api_url, {
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
          this.generations = json.generations
          this.totalPages = json.totalPages
          this.loaded = true
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    getCurrentPage() {
      const urlParams = new URLSearchParams(window.location.search)
      return Number(urlParams.get('page')) || 1
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.getGenerations()
      history.pushState(
        null,
        null,
        location.pathname + (pageNumber === 1 ? '' : `?page=${pageNumber}`)
      )
      window.scrollTo(0, 0)
    }
  }
}
</script>
