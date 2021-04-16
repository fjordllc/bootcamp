<template lang="pug">
  .page-body
    .container(v-if="loaded")
      nav.pagination
        pager(
          v-if="totalPages > 1 && products.length > 0"
          v-bind="pagerProps"
        )
      .thread-list.a-card(v-if="products.length > 0")
        .thread-list__items
          product(v-for="product in products"
            :key="product.id"
            :product="product"
            :currentUserId="currentUserId"
            :isMentor="isMentor")
        unconfirmed-links-open-button(v-if="isMentor && selectedTab != 'all'" :label="`${unconfirmedLinksName}の提出物を一括で開く`")
      .o-empty-message(v-else)
        .o-empty-message__icon
          i.far.fa-smile
        p.o-empty-message__text
          | {{ title }}はありません
      nav.pagination
        pager(
          v-if="totalPages > 1 && products.length > 0"
          v-bind="pagerProps"
        )
    .container(v-else)
      | ロード中
</template>

<script>
import Product from './product.vue'
import unconfirmedLinksOpenButton from './unconfirmed_links_open_button.vue'
import Pager from './pager.vue'

export default {
  props: ['title', 'selectedTab', 'isMentor', 'currentUserId'],
  components: {
    'product': Product,
    'unconfirmed-links-open-button': unconfirmedLinksOpenButton,
    pager: Pager
  },
  data() {
    return {
      products: [],
      totalPages: 0,
      currentPage: Number(this.getPageValueFromParameter()) || 1,
      loaded: false
    }
  },
  computed: {
    url () {
      return (
        '/api/products' +
        (this.selectedTab === 'all' ? '' : '/' + this.selectedTab.replace('-', '_')) +
        `?page=${this.currentPage}`
      )
    },
    unconfirmedLinksName() {
      return {
        unchecked: '未チェック',
        'not-responded': '未返信',
        'self-assigned': '自分の担当',
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
  created () {
    window.onpopstate = function(){
      location.replace(location.href);
    }
    this.getProductsPerPage()
  },
  methods: {
    token () {
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
        redirect: 'manual',
      })
      .then(response => {
        return response.json();
      })
      .then(json => {
        this.totalPages = json.total_pages
        this.products = []
        json.products.forEach(product => {
          this.products.push(product);
        });
        this.loaded = true
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
    },
    getPageValueFromParameter() {
      let url = location.href
      let results= url.match(/\?page=(\d+)/)
      if (!results) return null;
      return results[1]
    },
    paginateClickCallback (pageNumber) {
      this.currentPage = pageNumber
      this.getProductsPerPage()
      history.pushState(
        null,
        null,
        location.pathname + (pageNumber === 1 ? '' : `?page=${pageNumber}`),
      )
    }
  }
}
</script>
