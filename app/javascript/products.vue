<template lang="pug">
.page-body
  .container.is-md(v-if='!loaded')
    loadingListPlaceholder
  .container(v-else-if='products.length === 0')
    .o-empty-message
      .o-empty-message__icon
        i.fa-regular.fa-smile
      p.o-empty-message__text
        | {{ title }}はありません
  .container.is-md(v-else)
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .thread-list.a-card(v-if='productsGroupedByElapsedDays === null')
      .thread-list__items
        product(
          v-for='product in products',
          :key='product.id',
          :product='product',
          :currentUserId='currentUserId',
          :isMentor='isMentor'
        )
    template(v-for='product_n_days_passed in productsGroupedByElapsedDays') <!-- product_n_days_passedはn日経過の提出物 -->
      .thread-list.a-card
        header.card-header.a-elapsed-days.is-reply-warning(
          v-if='product_n_days_passed.elapsed_days === 5'
        )
          h2 {{ product_n_days_passed.elapsed_days }}日経過
        header.card-header.a-elapsed-days.is-reply-alert(
          v-else-if='product_n_days_passed.elapsed_days === 6'
        )
          h2 {{ product_n_days_passed.elapsed_days }}日経過
        header.card-header.a-elapsed-days.is-reply-deadline(
          v-else-if='product_n_days_passed.elapsed_days === 7'
        )
          h2 {{ product_n_days_passed.elapsed_days }}日以上経過
        header.card-header.a-elapsed-days(v-else)
          h2 {{ product_n_days_passed.elapsed_days }}日経過
        .thread-list__items
          product(
            v-for='product in product_n_days_passed.products',
            :key='product.id',
            :product='product',
            :currentUserId='currentUserId',
            :isMentor='isMentor'
          )
    unconfirmed-links-open-button(
      v-if='isMentor && selectedTab != "all"',
      :label='`${unconfirmedLinksName}の提出物を一括で開く`'
    )
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import Product from './product.vue'
import unconfirmedLinksOpenButton from './unconfirmed_links_open_button.vue'
import LoadingListPlaceholder from './loading-list-placeholder.vue'
import Pager from './pager.vue'

export default {
  components: {
    product: Product,
    'unconfirmed-links-open-button': unconfirmedLinksOpenButton,
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager
  },
  props: {
    title: { type: String, required: true },
    selectedTab: { type: String, required: true },
    isMentor: { type: Boolean, required: true },
    currentUserId: { type: String, required: true }
  },
  data() {
    return {
      products: [],
      totalPages: 0,
      currentPage: Number(this.getPageValueFromParameter()) || 1,
      loaded: false,
      productsGroupedByElapsedDays: null,
      params: this.getParams()
    }
  },
  computed: {
    url() {
      return (
        '/api/products' +
        (this.selectedTab === 'all'
          ? ''
          : '/' + this.selectedTab.replace('-', '_')) +
        `?page=${this.currentPage}` +
        (this.params.target ? `&target=${this.params.target}` : '')
      )
    },
    unconfirmedLinksName() {
      return {
        unchecked: '未完了',
        'self-assigned': '自分の担当',
        unassigned: '未アサイン'
      }[this.selectedTab]
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
    this.getProductsPerPage()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getProductsPerPage() {
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
          if (
            location.pathname === '/products/unassigned' ||
            location.pathname === '/products/unchecked'
          ) {
            this.productsGroupedByElapsedDays =
              json.products_grouped_by_elapsed_days
          }
          this.totalPages = json.total_pages
          this.products = []
          json.products.forEach((product) => {
            this.products.push(product)
          })
          this.loaded = true
        })
        .catch((error) => {
          console.warn(error)
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
      this.getProductsPerPage()
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
    }
  }
}
</script>
