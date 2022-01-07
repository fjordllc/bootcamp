<template lang="pug">
.page-body
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  .container
    .users
      .row.is-gutter-width-32(v-if='users === null')
        .empty
          .fas.fa-spinner.fa-pulse
          |
          | ロード中
      .row.is-gutter-width-32(v-else-if='users.length !== 0')
        user(
          v-for='user in users',
          :key='user.id',
          :user='user',
          :currentUser='currentUser'
        )
      .row.is-gutter-width-32(v-else)
        .o-empty-message
          .o-empty-message__icon
            i.far.fa-sad-tear
          p.o-empty-message__text
            | {{ targetName }}のユーザーはいません
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
</template>
<script>
import User from './user.vue'
import Pager from './pager.vue'

export default {
  components: {
    user: User,
    pager: Pager
  },
    props: {
    generationID: { type: String, required: true }
  },
  data() {
    return {
      users: null,
      currentUser: null,
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
        `/api/generations/${this.generationID}.json` +
        (this.params.tag ? `tags/${this.params.tag}` : '') +
        `?page=${this.currentPage}` +
        (this.params.target ? `&target=${this.params.target}` : '') +
        (this.params.watch ? `&watch=${this.params.watch}` : '')
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
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.getUsers()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getUsers() {
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
          this.users = []
          json.users.forEach((user) => {
            this.users.push(user)
          })
          this.currentUser = json.currentUser
          this.currentTarget = json.target
          this.currentTag = json.tag
          this.totalPages = json.totalPages
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
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
