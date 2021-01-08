<template lang="pug">
  .page-body
    .container
      nav.pagination.is-top
        .container
          pager-top(
            v-model='currentPage'
            :page-count="totalPages"
            :page-range=5
            :prev-text="`<i class='fas fa-angle-left'></i>`"
            :next-text="`<i class='fas fa-angle-right'></i>`"
            :first-button-text="`<i class='fas fa-angle-double-left'></i>`"
            :last-button-text="`<i class='fas fa-angle-double-right'></i>`"
            :click-handler="paginateClickCallback"
            :container-class="'pagination__items'"
            :page-class="'pagination__item'"
            :page-link-class="'pagination__item-link'"
            :disabled-class="'pager-disable'"
            :active-class="'is-active'"
            :prev-class="'is-prev pagination__item'"
            :prev-link-class="'is-prev pagination__item-link'"
            :next-class="'is-next pagination__item'"
            :next-link-class="'is-next pagination__item-link'"
            :first-last-button="true"
            :hide-prev-next="true"
            :margin-pages="0"
            :break-view-text="null"
          )
      .thread-list.a-card(v-if="products.length > 0")
        product(v-for="(product, index) in products"
          :key="product.id"
          :product="product")
        .thread-admin-tools(v-if="mentorLogin && selectedTab != 'all'")
          ul.thread-admin-tools__items
            li.thread-admin-tools__item
              button#js-shortcut-unconfirmed-links-open.thread-unconfirmed-links-form__action(class="a-button is-md is-primary")
                | {{ unconfirmedLinksName }}の提出物を一括で開く
      .o-empty-massage(v-else)
        .o-empty-massage__icon
          i.far.fa-smile
        p.o-empty-massage__text
          | {{ title }}はありません
      nav.pagination.is-bottom
        .container
          pager-bottom(
            v-model='currentPage'
            :page-count="totalPages"
            :page-range=5
            :prev-text="`<i class='fas fa-angle-left'></i>`"
            :next-text="`<i class='fas fa-angle-right'></i>`"
            :first-button-text="`<i class='fas fa-angle-double-left'></i>`"
            :last-button-text="`<i class='fas fa-angle-double-right'></i>`"
            :click-handler="paginateClickCallback"
            :container-class="'pagination__items'"
            :page-class="'pagination__item'"
            :page-link-class="'pagination__item-link'"
            :disabled-class="'pager-disable'"
            :active-class="'is-active'"
            :prev-class="'is-prev pagination__item'"
            :prev-link-class="'is-prev pagination__item-link'"
            :next-class="'is-next pagination__item'"
            :next-link-class="'is-next pagination__item-link'"
            :first-last-button="true"
            :hide-prev-next="true"
            :margin-pages="0"
            :break-view-text="null"
          )
</template>

<script>
import Product from './product.vue'
import VueJsPaginate from 'vuejs-paginate'

export default {
  props: ['title', 'selectedTab', 'mentorLogin'],
  components: {
    'product': Product,
    'pager-top': VueJsPaginate,
    'pager-bottom': VueJsPaginate
  },
  data: () => {
    return {
      products: [],
      totalPages: 0,
      currentPage: 1
    }
  },
  computed: {
    url () {
      switch (this.selectedTab) {
      case 'all':
        return `/api/products?page=${this.currentPage}`
      case 'unchecked':
        return `/api/products/unchecked?page=${this.currentPage}`
      case 'not-responded':
        return `/api/products/not_responded?page=${this.currentPage}`
      case 'self-assigned':
        return `/api/products/self_assigned?page=${this.currentPage}`
      }
    },
    unconfirmedLinksName() {
      if (this.selectedTab == 'unchecked') {
        return '未チェック'
      } else if (this.selectedTab == 'not-responded') {
        return '未返信'
      } else if (this.selectedTab == 'self-assigned') {
        return '自分の担当'
      }
    }
  },
  created () {
    window.onpopstate = function(){
      location.href = location.href
    }
    this.currentPage = Number(this.getPageValueFromParameter()) || 1
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
        json.products.forEach(c => {
          this.products.push(c);
        });
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
    },
    updateCurrentUrl() {
      let url = location.pathname
      if (this.currentPage != 1) {
        url += `?page=${this.currentPage}`
      }
      history.pushState(null, null, url)
    },
    getPageValueFromParameter() {
      let url = location.href
      let results= url.match(/\?page=(\d+)/)
      if (!results) return null;
      return results[1]
    },
    paginateClickCallback (pageNum) {
      this.getProductsPerPage()
      this.updateCurrentUrl()
    }
  }
}
</script>
