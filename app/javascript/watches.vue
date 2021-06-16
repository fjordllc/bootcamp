<template lang="pug">
.page-body
  .container(v-if='!loaded')
    | ロード中
  .container(v-else)
    nav.pagination
      pager(v-bind='pagerProps')
    label(v-if='watches.length')
      input(type='checkbox',v-model="checked")
      | 編集 
    .thread-list.a-card
     .thread-list__items
        watch(
         v-for='watch in watches',
         :key='watch.id',
         :watch='watch',
         :checked='checked',
         @updateIndex="updateIndex"
       )
    nav.pagination(v-if='totalPages > 1')
     pager(v-bind='pagerProps')
</template>

<script>
import watch from './watch.vue'
import Pager from './pager.vue'

export default {
  components: {
    watch: watch,
    pager: Pager
  },
 data() {
    return {
      watches: null,
      totalPages: 0,
      currentPage: this.pageParam(),
      loaded: false,
      checked:false,
    }
  },
  computed: {
    newParams(){
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
    pageParam(){
      const url = new URL(location.href)
      const page = url.searchParams.get('page')
      return parseInt(page || 1)
    },
    clickCallback(pageNum){
      this.currentPage = pageNum
      history.pushState(null, null, this.newURL)
      this.getWatches()
    },
    getWatches() {
      console.log(this.watchesAPI)
      fetch(this.watchesAPI, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.watches = []
          json.watches.forEach((r) => {
            this.watches.push(r)
          })
         this.totalPages = parseInt(json.totalPages)
         this.loaded = true
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
            },
    updateIndex(){
            this.getWatches()
        }
    },
}
</script>
