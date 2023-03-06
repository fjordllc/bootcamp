<template lang="pug">
.users
  .page-filter.form(v-if='users.length !== 0 && isAll')
    .container.is-md.has-no-x-padding
      .form__items
        .form-item.is-inline-md-up
          label.a-form-label
            | 絞り込み
          input#js-user-search-input.a-text-input(
            v-model.trim='searchUsersWord',
            placeholder='ユーザー名、読み方、Discord ID、GitHub ID など')
  .page-content.is-users
    .users__items
      .row(v-if='!loaded')
        loadingUsersListPlaceholder(v-for='num in itemCount', :key='num')
      div(v-else-if='users.length !== 0')
        .user-list(v-show='!showSearchedUsers')
          nav.pagination(v-if='totalPages > 1')
            pager(v-bind='pagerProps')
          .row
            user(
              v-for='user in users',
              :key='user.id',
              :user='user',
              :currentUser='currentUser')
          nav.pagination(v-if='totalPages > 1')
            pager(v-bind='pagerProps')
        .searched-user-list(v-show='showSearchedUsers')
          .o-empty-message(v-if='searchedUsers.length === 0')
            .o-empty-message__icon
              i.far.fa-sad-tear
            p.o-empty-message__text
              | 一致するユーザーはいません
          .row(v-else)
            user(
              v-for='user in searchedUsers',
              :key='user.id',
              :user='user',
              :currentUser='currentUser')
      .row(v-else)
        .o-empty-message
          .o-empty-message__icon
            i.fa-regular.fa-sad-tear
          p.o-empty-message__text
            | {{ targetName }}のユーザーはいません
</template>
<script>
import User from './user.vue'
import Pager from '../pager.vue'
import Debounce from '../debounce.js'
import LoadingUsersListPlaceholder from '../loading-users-list-placeholder.vue'

export default {
  name: 'Users',
  components: {
    user: User,
    pager: Pager,
    loadingUsersListPlaceholder: LoadingUsersListPlaceholder
  },
  data() {
    return {
      users: [],
      currentUser: null,
      currentTarget: null,
      currentTag: null,
      currentPage: Number(this.getParams().page) || 1,
      totalPages: 0,
      params: this.getParams(),
      searchUsersWord: '',
      showSearchedUsers: false,
      searchedUsers: [],
      loaded: false,
      itemCount: 12
    }
  },
  computed: {
    targetName() {
      return this.currentTag || this.currentTarget
    },
    url() {
      const params = this.addParams()
      return (
        '/api/users/' +
        (this.params.tag ? `tags/${this.params.tag}` : '') +
        `?page=${this.currentPage}` +
        (this.params.target ? `&target=${this.params.target}` : '') +
        (this.params.watch ? `&watch=${this.params.watch}` : '') +
        (params ? `&${params}` : '')
      )
    },
    pagerProps() {
      return {
        initialPageNumber: this.currentPage,
        pageCount: this.totalPages,
        pageRange: 5,
        clickHandle: this.paginateClickCallback
      }
    },
    isAll() {
      return (
        location.pathname === '/users' &&
        location.search !== '?target=followings'
      )
    }
  },
  watch: {
    searchUsersWord() {
      this.searchUsers()
    }
  },
  created() {
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.setupUsers()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    async fetchUsersResource() {
      const usersResource = await fetch(this.url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
      return usersResource.json()
    },
    setupUsers() {
      this.fetchUsersResource()
        .then((response) => {
          this.users.splice(0, this.users.length, ...response.users)
          this.currentUser = response.currentUser
          this.currentTarget = response.target
          this.currentTag = response.tag
          this.totalPages = response.totalPages
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
      if (location.pathname.match(/tags/)) {
        const tag = location.pathname.split('/').pop()
        params.tag = tag
      }
      return params
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.setupUsers()
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
    validateSearchUsersWord() {
      if (this.searchUsersWord.match(/^[\w-]+$/))
        return this.searchUsersWord.length >= 3
      return this.searchUsersWord.length >= 2
    },
    searchUsers: Debounce(function () {
      this.showSearchedUsers = false
      if (!this.validateSearchUsersWord()) return
      this.setupSearchedUsers()
      this.showSearchedUsers = true
    }, 500),
    setupSearchedUsers() {
      this.loaded = false
      this.fetchUsersResource()
        .then((response) => {
          this.searchedUsers.splice(
            0,
            this.searchedUsers.length,
            ...response.users
          )
          this.loaded = true
        })
        .catch((error) => console.warn(error))
    },
    addParams() {
      if (!this.validateSearchUsersWord()) return
      const params = new URL(location.origin).searchParams
      params.set('search_word', this.searchUsersWord)
      return params
    }
  }
}
</script>
