<template lang="pug">
.page-body
  .container.is-md(v-if='!loaded')
    loadingListPlaceholder
  .container.is-md(v-else)
    .thread-list-tools(v-if='watches.length')
      .form-item.is-inline
        label.a-form-label(for='thread-list-tools__action')
          | 編集
        label.a-on-off-checkbox.is-sm
          input#thread-list-tools__action(
            type='checkbox',
            name='thread-list-tools__action',
            v-model='checked'
          )
          span#spec-edit-mode
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .thread-list.a-card
      .thread-list__items
        watch(
          v-for='watch in watches',
          :key='watch.id',
          :watch='watch',
          :checked='checked',
          @updateIndex='updateIndex'
        )
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import watch from './watch.vue'
import Pager from './pager.vue'
import LoadingListPlaceholder from './loading-list-placeholder.vue'

export default {
  components: {
    watch: watch,
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager
  },
  data() {
    return {
      watches: null,
      totalPages: 0,
      currentPage: this.pageParam(),
      loaded: false,
      checked: false
    }
  },
  computed: {
    newParams() {
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      return params
    },
    watchesAPI() {
      const params = this.newParams
      return `/api/watches.json?${params}`
    },
    newURL() {
      return `${location.pathname}?${this.newParams}`
    },
    pagerProps() {
      return {
        initialPageNumber: this.currentPage,
        pageCount: this.totalPages,
        pageRange: 5,
        clickHandle: this.clickCallback
      }
    }
  },
  created() {
    window.onpopstate = () => {
      this.currentPage = this.pageParam()
      this.getWatches()
    }
    this.getWatches()
  },
  methods: {
    pageParam() {
      const url = new URL(location.href)
      const page = url.searchParams.get('page')
      return parseInt(page || 1)
    },
    clickCallback(pageNum) {
      this.currentPage = pageNum
      history.pushState(null, null, this.newURL)
      this.getWatches()
      window.scrollTo(0, 0)
    },
    async getWatches() {
      const response = await fetch(this.watchesAPI, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      }).catch((error) => console.warn(error))
      const json = await response.json().catch((error) => console.warn(error))
      this.watches = json.watches ? json.watches : []
      this.totalPages = parseInt(json.totalPages)
      this.loaded = true
    },
    updateIndex() {
      this.getWatches()
    }
  }
}
</script>
