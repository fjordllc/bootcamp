<template lang="pug">
.page-main
  .page-filter.form
    .container.is-md
      .form__items
        .form-item.is-inline-md-up
          label.a-form-label
            | 絞り込み
          input#js-talk-search-input.a-text-input(
            v-model.trim='searchTalksWord',
            placeholder='ユーザーID、ユーザー名、読み方、Discord ID など')
  hr.a-border
  .page-body
    .container.is-md
      #talks.page-content.loading(v-if='!loaded')
        loadingListPlaceholder
      .o-empty-message(v-else-if='talks.length === 0')
        .o-empty-message__icon
          i.fa-regular.fa-smile
        p.o-empty-message__text
          | 未対応の相談部屋はありません
      #talks.page-content.loaded(v-else)
        .talk-list(v-show='!showSearchedTalks')
          nav.pagination(v-if='totalPages > 1')
            pager(v-bind='pagerProps')
          .card-list.a-card
            talk(
              v-for='talk in talks',
              :key='talk.id',
              :user='talk.user',
              :talk='talk')
          nav.pagination(v-if='totalPages > 1')
            pager(v-bind='pagerProps')
        .searched-talk-list(v-show='showSearchedTalks')
          .o-empty-message(v-if='searchedTalks.length === 0')
            .o-empty-message__icon
              i.far.fa-sad-tear
            p.o-empty-message__text
              | 一致する相談部屋はありません
          .card-list.a-card(v-else)
            talk(
              v-for='talk in searchedTalks',
              :key='talk.id',
              :user='talk.user',
              :talk='talk')
</template>
<script>
import CSRF from 'csrf'
import Talk from 'components/talk.vue'
import LoadingListPlaceholder from 'loading-list-placeholder.vue'
import Pager from 'pager.vue'
import { debounce } from 'lodash'

export default {
  name: 'Talks',
  components: {
    talk: Talk,
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager
  },
  data() {
    return {
      talks: [],
      currentPage: this.pageParam(),
      loaded: false,
      totalPages: null,
      searchTalksWord: '',
      searchedTalks: [],
      showSearchedTalks: false
    }
  },
  computed: {
    isActionUncompletedPage() {
      return location.pathname.includes('action_uncompleted')
    },
    url() {
      const params = this.newParams
      if (this.isActionUncompletedPage) {
        return `/api/talks/action_uncompleted.json?${params}`
      } else {
        return `/api/talks.json?${params}`
      }
    },
    newParams() {
      const params = new URL(location.href).searchParams
      if (this.validateSearchTalksWord()) {
        params.set('search_word', this.searchTalksWord)
      } else {
        params.set('page', this.currentPage)
      }
      return params
    },
    pagerProps() {
      return {
        initialPageNumber: this.currentPage,
        pageCount: this.totalPages,
        pageRange: 9,
        clickHandle: this.clickCallback
      }
    },
    newURL() {
      return `${location.pathname}?${this.newParams}`
    }
  },
  watch: {
    searchTalksWord() {
      this.searchTalks()
    }
  },
  created() {
    this.currentPage = this.pageParam()
    this.setupTalks()
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
      this.setupTalks()
      window.scrollTo(0, 0)
    },
    async fetchTalksResource() {
      const talksResource = await fetch(this.url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
      return talksResource.json()
    },
    setupTalks() {
      this.fetchTalksResource()
        .then((response) => {
          this.talks.splice(0, this.talks.length, ...response.talks)
          this.totalPages = response.totalPages
          this.loaded = true
        })
        .catch((error) => console.warn(error))
    },
    searchTalks: debounce(function () {
      this.showSearchedTalks = false
      if (!this.validateSearchTalksWord()) return

      this.loaded = false
      this.setupSearchedTalks()
      this.showSearchedTalks = true
    }, 500),
    validateSearchTalksWord() {
      if (this.searchTalksWord.match(/^[\w-]+$/)) {
        return this.searchTalksWord.length >= 3
      } else {
        return this.searchTalksWord.length >= 2
      }
    },
    setupSearchedTalks() {
      this.fetchTalksResource()
        .then((response) => {
          this.searchedTalks.splice(
            0,
            this.searchedTalks.length,
            ...response.talks
          )
          this.loaded = true
        })
        .catch((error) => console.warn(error))
    }
  }
}
</script>
