<template lang="pug">
.page-body
  .container.is-md(v-if='!loaded')
    loadingListPlaceholder
  .container(v-else-if='announcements.length === 0')
    .o-empty-message
      .o-empty-message__icon
        i.far.fa-smile
      p.o-empty-message__text
        | {{ title }}はありません
  .container.is-md(v-else)
    nav.o-pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
    .thread-list.a-card
      announcement(
        v-for='announcement in announcements',
        :key='announcement.id',
        :title='title',
        :announcement='announcement',
        :currentUser='currentUser'
      )
    nav.o-pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import LoadingListPlaceholder from './loading-list-placeholder.vue'
import Announcement from './announcement.vue'
import Pager from './pager.vue'

export default {
  components: {
    loadingListPlaceholder: LoadingListPlaceholder,
    announcement: Announcement,
    pager: Pager
  },
  props: {
    title: { type: String, required: true },
    currentUserId: { type: String, required: true }
  },
  data() {
    return {
      announcements: [],
      totalPages: 0,
      currentPage: Number(this.getPageValueFromParameter()) || 1,
      loaded: false,
      currentUser: {}
    }
  },
  computed: {
    url() {
      return `/api/announcements?page=${this.currentPage}`
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
    this.getAnnouncementsPerPage()
    this.getCurrentUser()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getAnnouncementsPerPage() {
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
          this.totalPages = json.total_pages
          this.announcements = []
          json.announcements.forEach((announcement) => {
            this.announcements.push(announcement)
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
      this.getAnnouncementsPerPage()
      history.pushState(
        null,
        null,
        location.pathname + (pageNumber === 1 ? '' : `?page=${pageNumber}`)
      )
    },
    getCurrentUser() {
      fetch(`/api/users/${this.currentUserId}.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          for (const key in json) {
            this.$set(this.currentUser, key, json[key])
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
