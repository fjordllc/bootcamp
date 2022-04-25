<template lang="pug">
.page-body
  .container(v-if='!loaded')
    loadingListPlaceholder
  .container(v-if='products.length === 0')
    .o-empty-message
      .o-empty-message__icon
        i.far.fa-smile
      p.o-empty-message__text
        | {{ title }}はありません
  .container.is-md(v-else)
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .thread-list.a-card
      .thread-list__items
        product(
          v-for='product in products',
          :key='product.id',
          :product='product',
          :currentUserId='currentUserId',
          :isMentor='isMentor'
        )
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import Pager from 'pager.vue'
import Product from 'product.vue'
import LoadingListPlaceholder from './loading-list-placeholder.vue'

export default {
  components: {
    product: Product,
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager
  },
  props: {
    companyID: { type: String, required: true },
    title: { type: String, required: true },
    isMentor: { type: Boolean, required: true },
    currentUserId: { type: String, required: true }
  },
  data() {
    return {
      loaded: false,
      products: [],
      currentPage: Number(this.getParams().page) || 1,
      totalPages: 0,
      params: this.getParams()
    }
  },
  computed: {
    url() {
      return (
        '/api/products/' +
        `?page=${this.currentPage}` +
        (this.companyID ? `&company_id=${this.companyID}` : '')
      )
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
      location.replace(location.href)
    }
    this.getProducts()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getProducts() {
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
          this.products = []
          json.products.forEach((product) => {
            this.products.push(product)
          })
          this.totalPages = json.total_pages
          this.loaded = true
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    getParams() {
      const params = {}
      location.search
        .slice(1)
        .split('&')
        .forEach((query) => {
          const queryArr = query.split('=')
          params[queryArr[0]] = queryArr[1]
        })
      return params
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.getProducts()
      history.pushState(null, null, this.newUrl(pageNumber))
      window.scrollTo(0, 0)
    },
    newUrl(pageNumber) {
      return location.pathname + (pageNumber === 1 ? '' : `?page=${pageNumber}`)
    }
  }
}
</script>
