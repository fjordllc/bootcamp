<template lang="pug">
  .page-body
    .container(v-if="loaded")
      nav.pagination
        pager-top(
          v-if="totalPages > 1 && announcements.length > 0"
          v-model='currentPage'
          :page-count="totalPages"
          :page-range=5
          :prev-text="`<i class='fas fa-angle-left'></i>`"
          :next-text="`<i class='fas fa-angle-right'></i>`"
          :first-button-text="`<i class='fas fa-angle-double-left'></i>`"
          :last-button-text="`<i class='fas fa-angle-double-right'></i>`"
          :click-handler="paginateClickCallback"
          :container-class="'pagination__items'"
          :page-class="'pagination__item'"
          :page-link-class="'pagination__item-link'"
          :disabled-class="'is-disabled'"
          :active-class="'is-active'"
          :prev-class="'is-prev pagination__item'"
          :prev-link-class="'is-prev pagination__item-link'"
          :next-class="'is-next pagination__item'"
          :next-link-class="'is-next pagination__item-link'"
          :first-last-button="true"
          :hide-prev-next="true"
          :margin-pages="0"
          :break-view-text="null"
        )
      .thread-list.a-card(v-if="announcements.length > 0")
        announcement(v-for="announcement in announcements"
          :key="announcement.id"
          :title="title"
          :announcement="announcement"
          :currentUser="currentUser")
      .o-empty-massage(v-else)
        .o-empty-massage__icon
          i.far.fa-smile
        p.o-empty-massage__text
          | {{ title }}はありません
      nav.pagination
        pager-bottom(
          v-if="totalPages > 1 && announcements.length > 0"
          v-model='currentPage'
          :page-count="totalPages"
          :page-range=5
          :prev-text="`<i class='fas fa-angle-left'></i>`"
          :next-text="`<i class='fas fa-angle-right'></i>`"
          :first-button-text="`<i class='fas fa-angle-double-left'></i>`"
          :last-button-text="`<i class='fas fa-angle-double-right'></i>`"
          :click-handler="paginateClickCallback"
          :container-class="'pagination__items'"
          :page-class="'pagination__item'"
          :page-link-class="'pagination__item-link'"
          :disabled-class="'is-disabled'"
          :active-class="'is-active'"
          :prev-class="'is-prev pagination__item'"
          :prev-link-class="'is-prev pagination__item-link'"
          :next-class="'is-next pagination__item'"
          :next-link-class="'is-next pagination__item-link'"
          :first-last-button="true"
          :hide-prev-next="true"
          :margin-pages="0"
          :break-view-text="null"
        )
    .container(v-else)
      | ロード中
</template>

<script>
import Announcement from './announcement.vue'
import VueJsPaginate from 'vuejs-paginate'

export default {
  props: ['title', 'currentUserId'],
  components: {
    'announcement': Announcement,
    'pager-top': VueJsPaginate,
    'pager-bottom': VueJsPaginate
  },
  data: () => {
    return {
      announcements: [],
      totalPages: 0,
      currentPage: 1,
      loaded: false,
      currentUser: {}
    }
  },
  computed: {
    url () { return `/api/announcements?page=${this.currentPage}` }
  },
  created () {
    window.onpopstate = function(){
      location.href = location.href
    }
    this.currentPage = Number(this.getPageValueFromParameter()) || 1
    this.getAnnouncementsPerPage()
    this.getCurrentUser()
  },
  methods: {
    token () {
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
        redirect: 'manual',
      })
      .then(response => {
        return response.json();
      })
      .then(json => {
        this.totalPages = json.total_pages
        this.announcements = []
        json.announcements.forEach(announcement => {
          this.announcements.push(announcement);
        });
        this.loaded = true
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
    },
    updateCurrentUrl() {
      let url = location.pathname
      if (this.currentPage != 1) {
        url += `?page=${this.currentPage}`
      }
      history.pushState(null, null, url)
    },
    getPageValueFromParameter() {
      let url = location.href
      let results= url.match(/\?page=(\d+)/)
      if (!results) return null;
      return results[1]
    },
    paginateClickCallback (pageNum) {
      this.getAnnouncementsPerPage()
      this.updateCurrentUrl()
    },
    getCurrentUser() {
      fetch(`/api/users/${this.currentUserId}.json`, {
      method: "GET",
      headers: {
        "X-Requested-With": "XMLHttpRequest"
      },
      credentials: "same-origin",
      redirect: "manual"
    })
      .then(response => {
        return response.json();
      })
      .then(json => {
        for (var key in json) {
          this.$set(this.currentUser, key, json[key]);
        }
      })
      .catch(error => {
        console.warn("Failed to parsing", error);
      });
    }
  }
}
</script>
