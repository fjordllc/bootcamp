<template lang="pug">
.page-body
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  .container
    .products
      .row(v-if='products === null')
        .empty
          .fas.fa-spinner.fa-pulse
          |
          | ロード中
      .row(v-else-if='products.length !== 0')
        product(
          v-for='product in products',
          :key='product.id',
          :product='product',
          :currentProduct='currentProduct'
        )
      .row(v-else)
        .o-empty-message
          .o-empty-message__icon
            i.far.fa-sad-tear
          p.o-empty-message__text
            | {{ targetName }}の提出物はありません
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
</template>
<script>
import Pager from 'pager.vue'
import Product from 'product.vue'

export default {
  components: {
    product: Product,
    pager: Pager
  },
  props: {
    companyID: { type: String, required: true }
  },
  data() {
    return {
      products: null,
      currentProduct: null,
      currentTarget: null,
      currentTag: null,
      currentPage: Number(this.getParams().page) || 1,
      totalPages: 0,
      params: this.getParams()
    }
  },
  computed: {
    targetName() {
      return this.currentTag || this.currentTarget
    },
    url() {
      return (
          '/api/products/' +
          (this.params.tag ? `tags/${this.params.tag}` : '') +
          `?page=${this.currentPage}` +
          (this.params.target ? `&target=${this.params.target}` : '') +
          (this.params.watch ? `&watch=${this.params.watch}` : '') +
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
            this.currentProduct = json.currentProduct
            this.currentTarget = json.target
            this.currentTag = json.tag
            this.totalPages = json.totalPages
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
      if (location.pathname.match(/tags/)) {
        const tag = location.pathname.split('/').pop()
        params.tag = tag
      }
      return params
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.getUsers()
      history.pushState(null, null, this.newUrl(pageNumber))
      window.scrollTo(0, 0)
    },
    newUrl(pageNumber) {
      if (this.params.target) {
        return (
            location.pathname +
            `?target=${this.params.target}` +
            (pageNumber === 1 ? '' : `&page=${pageNumber}`)
        )
      } else {
        return (
            location.pathname + (pageNumber === 1 ? '' : `?page=${pageNumber}`)
        )
      }
    }
  }
}
</script>
