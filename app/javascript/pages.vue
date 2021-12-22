<template lang="pug">
.two-columns__inner
  .thread-list.a-card
    page(v-for='page in pages', :key='page.id', :page='page')
</template>

<script>
import Page from './page.vue'

export default {
  components: {
    page: Page
  },
  props: {
    title: { type: String, required: true },
    currentUserId: { type: String, required: true }
  },
  data() {
    return {
      pages: [],
      currentPage: Number(this.getPageValueFromParameter()) || 1,
      currentUser: {}
    }
  },
  computed: {
    url() {
      return `/api/pages?page=${this.currentPage}`
    }
  },
  created() {
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.getPagesPerPage()
    this.getCurrentUser()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getPagesPerPage() {
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
          this.pages = []
          json.pages.forEach((page) => {
            this.pages.push(page)
          })
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    getPageValueFromParameter() {
      const url = location.href
      const results = url.match(/\?page=(\d+)/)
      if (!results) return null
      return results[1]
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
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
