<template lang="pug">
#notifications.container.is-md.loaing(v-if='!loaded')
  loadingListPlaceholder
.container(v-else-if='notifications.length === 0')
  .o-empty-message
    .o-empty-message__icon
      i.far.fa-smile
    p.o-empty-message__text(v-if='isUnreadPage')
      | 未読の通知はありません
    p.o-empty-message__text(v-else)
      | 通知はありません
#notifications.container.is-md.loaded(v-else)
  nav.o-pagination(v-if='totalPages > 1')
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
  nav.o-pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
</template>

<script>
import Notification from './notification.vue'
import LoadingListPlaceholder from './loading-list-placeholder.vue'
import Pager from './pager.vue'
import UnconfirmedLinksOpenButton from './unconfirmed_links_open_button'

export default {
  components: {
    notification: Notification,
    loadingListPlaceholder: LoadingListPlaceholder,
    pager: Pager,
    'unconfirmed-links-open-button': UnconfirmedLinksOpenButton
  },
  props: {
    isMentor: {
      type: Boolean
    },
    target: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      notifications: [],
      totalPages: 0,
      currentPage: Number(this.getPageValueFromParameter()) || 1,
      loaded: false
    }
  },
  computed: {
    url() {
      if (this.isUnreadPage) {
        return `/api/notifications.json?page=${this.currentPage}&status=unread&target=${this.target}`
      } else {
        return `/api/notifications.json?page=${this.currentPage}&target=${this.target}`
      }
    },
    isUnreadPage() {
      const params = new URLSearchParams(location.search)
      return params.get('status') !== null && params.get('status') === 'unread'
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
    // ブラウザバック・フォワードした時に画面を読み込ませる
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.getNotificationsPerPage()
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
          console.warn(error)
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
