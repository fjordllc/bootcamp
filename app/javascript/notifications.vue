<template lang="pug">
  .div
    .pagination
      nav.container
        pager-top(
          v-if="totalPages > 1"
          v-model='currentPage'
          :page-count="totalPages"
          :page-range="5"
          :prev-text="`<i class='fas fa-angle-left'></i>`"
          :next-text="`<i class='fas fa-angle-right'></i>`"
          :first-button-text="`<i class='fas fa-angle-double-left'></i>`"
          :last-button-text="`<i class='fas fa-angle-double-right'></i>`"
          :click-handler="paginateClickCallback"
          :container-class="'pagination__items'"
          :page-class="'pagination__item'"
          :page-link-class="'pagination__item-link'"
          :disabled-class="'pager-disable'"
          :active-class="'is-active'"
          :prev-class="'is-prev pagination__item'"
          :prev-link-class="'is-prev pagination__item-link'"
          :next-class="'is-next pagination__item'"
          :next-link-class="'is-next pagination__item-link'"
          :first-last-button="true"
          :hide-prev-next="true"
          :margin-pages="0"
          :break-view-text=null
        )
    .thread-list.a-card
      notification(v-for="(notification, index) in notifications"
        :key="notification.id"
        :notification="notification")
    .pagination
      nav.container
        pager-bottom(
          v-if="totalPages > 1"
          v-model='currentPage'
          :page-count="totalPages"
          :page-range="5"
          :prev-text="`<i class='fas fa-angle-left'></i>`"
          :next-text="`<i class='fas fa-angle-right'></i>`"
          :first-button-text="`<i class='fas fa-angle-double-left'></i>`"
          :last-button-text="`<i class='fas fa-angle-double-right'></i>`"
          :click-handler="paginateClickCallback"
          :container-class="'pagination__items'"
          :page-class="'pagination__item'"
          :page-link-class="'pagination__item-link'"
          :disabled-class="'pager-disable'"
          :active-class="'is-active'"
          :prev-class="'is-prev pagination__item'"
          :prev-link-class="'is-prev pagination__item-link'"
          :next-class="'is-next pagination__item'"
          :next-link-class="'is-next pagination__item-link'"
          :first-last-button="true"
          :hide-prev-next="true"
          :margin-pages="0"
          :break-view-text=null
        )
</template>

<script>
import Notification from './notification.vue'
import VueJsPaginate from "vuejs-paginate"

export default {
  components: {
    'notification': Notification,
    'pager-top': VueJsPaginate,
    'pager-bottom': VueJsPaginate
  },
  data: () => {
    return {
      notifications: [],
      totalPages: 0,
      currentPage: null,
    }
  },
  created() {
    // ブラウザバック・フォワードした時に画面を読み込ませる
    window.onpopstate=function(){
      location.href = location.href
    }
    this.currentPage = Number(this.getPageValueFromParameter()) || 1
    this.getNotificationsPerPage()
  },
  computed: {
    url() {
      if(location.pathname.includes('unread')){
        return `/api/notifications/unread.json?page=${this.currentPage}`
      }else{
        return `/api/notifications.json?page=${this.currentPage}`
      }
    }
  },
  methods: {
    getNotificationsPerPage: function(){
      fetch(this.url, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest'},
        credentials: 'same-origin',
        redirect: 'manual'
      })
      .then(response => {
        return response.json()
      })
        .then(json => {
          this.totalPages = json['total_pages']
          this.notifications = []
          json['notifications'].forEach(n => { this.notifications.push(n) })
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
    updateCurrentUrl: function(){
      let url = location.pathname
      if (this.currentPage!=1){
        url+=`?page=${this.currentPage}`
      }
      history.pushState(null,null,url)
    },
    paginateClickCallback: function () {
      this.getNotificationsPerPage()
      this.updateCurrentUrl()
    },
    getPageValueFromParameter: function() {
      let url = location.href
      let results= url.match(/\?page=(\d+)/)
      if (!results) return null;
      return results[1]
    }
  }
}
</script>

<style>
.pager-disable{
  display: none;
}

.pagination__item-link{
  outline: none;
}
</style>
