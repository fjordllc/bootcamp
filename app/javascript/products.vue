<template lang="pug">
.products(v-if='!loaded')
  loadingListPlaceholder
.o-empty-message(v-else-if='products.length === 0')
  .o-empty-message__icon
    i.fa-regular.fa-smile
  p.o-empty-message__text
    | {{ title }}はありません
.products(v-else)
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  .a-card(v-if='productsGroupedByElapsedDays === null')
    .card-list
      .card-list__items
        product(
          v-for='product in products',
          :key='product.id',
          :product='product',
          :currentUserId='currentUserId',
          :isMentor='isMentor'
        )
  template(v-for='product_n_days_passed in productsGroupedByElapsedDays') <!-- product_n_days_passedはn日経過の提出物 -->
    .a-card(
      v-if='!isDashboard || (isDashboard && product_n_days_passed.elapsed_days >= 5)'
    )
      header.card-header.a-elapsed-days(
        v-if='product_n_days_passed.elapsed_days === 0'
      )
        h2.card-header__title
          | 今日提出
          span.card-header__count(v-if='selectedTab === "unassigned"')
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      header.card-header.a-elapsed-days.is-reply-warning(
        v-else-if='product_n_days_passed.elapsed_days === 5'
      )
        h2.card-header__title
          | {{ product_n_days_passed.elapsed_days }}日経過
          span.card-header__count(v-if='selectedTab === "unassigned"')
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      header.card-header.a-elapsed-days.is-reply-alert(
        v-else-if='product_n_days_passed.elapsed_days === 6'
      )
        h2.card-header__title
          | {{ product_n_days_passed.elapsed_days }}日経過
          span.card-header__count(v-if='selectedTab === "unassigned"')
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      header.card-header.a-elapsed-days.is-reply-deadline(
        v-else-if='product_n_days_passed.elapsed_days === 7'
      )
        h2.card-header__title
          | {{ product_n_days_passed.elapsed_days }}日以上経過
          span.card-header__count(v-if='selectedTab === "unassigned"')
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      header.card-header.a-elapsed-days(v-else)
        h2.card-header__title
          | {{ product_n_days_passed.elapsed_days }}日経過
          span.card-header__count(v-if='selectedTab === "unassigned"')
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      .card-list(:class='listClassName')
        .card-list__items
          product(
            v-for='product in product_n_days_passed.products',
            :key='product.id',
            :product='product',
            :currentUserId='currentUserId',
            :isMentor='isMentor'
          )
  unconfirmed-links-open-button(
    v-if='isMentor && selectedTab != "all" && !isDashboard',
    :label='`${unconfirmedLinksName}の提出物を一括で開く`'
  )
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
</template>

<script>
import Product from 'product.vue'
import unconfirmedLinksOpenButton from 'unconfirmed_links_open_button.vue'
import LoadingListPlaceholder from 'loading-list-placeholder.vue'
import Pager from 'pager.vue'

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
    currentUserId: { type: String, required: true },
    checkerId: { type: String, required: false, default: null }
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
        (this.checkerId ? `&checker_id=${this.checkerId}` : '') +
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
    },
    listClassName() {
      return this.isDashboard ? 'has-scroll' : ''
    },
    isDashboard() {
      return location.pathname === '/'
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
            location.pathname === '/products/unchecked' ||
            location.pathname === '/'
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
      const params = new URL(location.href).searchParams
      if (pageNumber !== 1) params.set('page', pageNumber);
      if (this.params.target) params.set('target', this.params.target);
      if (this.params.checker_id) params.set('checker_id', this.params.checker_id);
      return `${location.pathname}?${params}`
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
    countProductsGroupedBy({ elapsed_days: elapsedDays }) {
      const element = this.productsGroupedByElapsedDays.find(
        (el) => el.elapsed_days === elapsedDays
      )
      return element === undefined ? 0 : element.products.length
    }
  }
}
</script>
