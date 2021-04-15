<template lang="pug">
.container(v-if='!loaded')
  | ロード中
.container(v-else-if='notifications.length === 0')
  .o-empty-message
    .o-empty-message__icon
      i.far.fa-smile
    p.o-empty-message__text(v-if='isUnreadPage')
      | 未読の通知はありません
    p.o-empty-message__text(v-else)
      | 通知はありません
.container(v-else)
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  .thread-list.a-card
    notification(
      v-for='notification in notifications',
      :key='notification.id',
      :notification='notification'
    )
    unconfirmed-links-open-button(
      v-if='isMentor && isUnreadPage',
      label='未読の通知を一括で開く'
    )
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
</template>

<script>
import Notification from './notification.vue'
import Pager from './pager.vue'
import UnconfirmedLinksOpenButton from './unconfirmed_links_open_button'

export default {
  props: {
    isMentor: {
      type: Boolean
    }
  },
  components: {
    notification: Notification,
    pager: Pager,
    'unconfirmed-links-open-button': UnconfirmedLinksOpenButton
  },
  data() {
    return {
      notifications: [],
      totalPages: 0,
      currentPage: Number(this.getPageValueFromParameter()) || 1,
      loaded: false
    }
  },
  created() {
    // ブラウザバック・フォワードした時に画面を読み込ませる
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.getNotificationsPerPage()
  },
  computed: {
    url() {
      if (this.isUnreadPage) {
        return `/api/notifications/unread.json?page=${this.currentPage}`
      } else {
        return `/api/notifications.json?page=${this.currentPage}`
      }
    },
    isUnreadPage() {
      return location.pathname.includes('unread')
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
  methods: {
    getNotificationsPerPage: function () {
      fetch(this.url, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.totalPages = json.total_pages
          this.notifications = []
          json.notifications.forEach((n) => {
            this.notifications.push(n)
          })
          this.loaded = true
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    paginateClickCallback: function (pageNumber) {
      this.currentPage = pageNumber
      this.getNotificationsPerPage()
      history.pushState(
        null,
        null,
        location.pathname + (pageNumber === 1 ? '' : `?page=${pageNumber}`)
      )
    },
    getPageValueFromParameter: function () {
      const url = location.href
      const results = url.match(/\?page=(\d+)/)
      if (!results) return null
      return results[1]
    }
  }
}
</script>
