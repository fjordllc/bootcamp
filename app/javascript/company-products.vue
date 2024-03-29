<template lang="pug">
.page-body
  .container.is-md(v-if='!loaded')
    loadingListPlaceholder
  .container.is-md(v-else-if='products.length === 0')
    .o-empty-message
      .o-empty-message__icon
        i.far.fa-smile
      p.o-empty-message__text
        | {{ title }}はありません
  .container.is-md(v-else)
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .card-list.a-card
      .card-list__items
        product(
          v-for='product in products',
          :key='product.id',
          :product='product',
          :currentUserId='currentUserId',
          :isMentor='isMentor')
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import CSRF from 'csrf'
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
    currentUserId: { type: Number, required: true }
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
    getProducts() {
      fetch(this.url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
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
