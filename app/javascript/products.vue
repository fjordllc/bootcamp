<template lang="pug">
  .page-body
    .container(v-if="loaded")
      nav.pagination
        pager-top(
          v-if="totalPages > 1 && products.length > 0"
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
          :disabled-class="'is-disabled'"
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
        pager-bottom(
          v-if="totalPages > 1 && products.length > 0"
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
          :disabled-class="'is-disabled'"
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
    .container(v-else)
      | ロード中
</template>

<script>
import Product from './product.vue'
import unconfirmedLinksOpenButton from './unconfirmed_links_open_button.vue'
import VueJsPaginate from 'vuejs-paginate'

export default {
  props: ['title', 'selectedTab', 'isMentor', 'currentUserId'],
  components: {
    'product': Product,
    'unconfirmed-links-open-button': unconfirmedLinksOpenButton,
    'pager-top': VueJsPaginate,
    'pager-bottom': VueJsPaginate
  },
  data: () => {
    return {
      products: [],
      totalPages: 0,
      currentPage: 1,
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
    }
  },
  created () {
    window.onpopstate = function(){
      location.replace(location.href);
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
        json.products.forEach(product => {
          this.products.push(product);
        });
        this.loaded = true
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
    paginateClickCallback () {
      this.getProductsPerPage()
      this.updateCurrentUrl()
    }
  }
}
</script>
