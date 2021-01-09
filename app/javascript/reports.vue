<template lang="pug">
  .reports
    .empty(v-if="reports === null")
      .fas.fa-spinner.fa-pulse
      |  ロード中
    .reports__items(v-else-if="reports.length > 0 || !isUncheckedReportsPage")
      paginate(
        v-if="totalPages > 1"
        v-model="currentPage"
        :page-count="totalPages"
        :page-range="9"
        :margin-pages="0"
        :click-handler="clickCallback"
        :prev-text="`<i class='fas fa-angle-left'></i>`"
        :next-text="`<i class='fas fa-angle-right'></i>`"
        :break-view-text="''"
        :first-last-button="true"
        :first-button-text="`<i class='fas fa-angle-double-left'></i>`"
        :last-button-text="`<i class='fas fa-angle-double-right'></i>`"
        :container-class="'page-body pagination__items container'"
        :page-class="'pagination__item'"
        :page-link-class="'pagination__item-link'"
        :prev-class="'pagination__item is-prev'"
        :prev-link-class="'pagination__item-link is-prev'"
        :next-class="'pagination__item is-next'"
        :next-link-class="'pagination__item-link is-next'"
        :active-class="'is-active'"
        :active-link-class="'is-active'"
        :hide-prev-next="true")
      .reports__items
        .thread-list.a-card
          report(
            v-for="report in reports"
            :key="report.id"
            :report="report"
            :current-user-id="currentUserId")
      unconfirmed-link(
        v-if="isUncheckedReportsPage"
        label="未チェックの日報を一括で開く")
      paginate(
        v-if="totalPages > 1"
        v-model="currentPage"
        :page-count="totalPages"
        :page-range="9"
        :margin-pages="0"
        :click-handler="clickCallback"
        :prev-text="`<i class='fas fa-angle-left'></i>`"
        :next-text="`<i class='fas fa-angle-right'></i>`"
        :break-view-text="''"
        :first-last-button="true"
        :first-button-text="`<i class='fas fa-angle-double-left'></i>`"
        :last-button-text="`<i class='fas fa-angle-double-right'></i>`"
        :container-class="'page-body pagination__items container'"
        :page-class="'pagination__item'"
        :page-link-class="'pagination__item-link'"
        :prev-class="'pagination__item is-prev'"
        :prev-link-class="'pagination__item-link is-prev'"
        :next-class="'pagination__item is-next'"
        :next-link-class="'pagination__item-link is-next'"
        :active-class="'is-active'"
        :active-link-class="'is-active'"
        :hide-prev-next="true")
    .o-empty-massage(v-else)
      .o-empty-massage__icon
        i.far.fa-smile
      p.o-empty-massage__text
        | 未チェックの日報はありません
</template>
<script>
import Report from './report.vue'
import UnconfirmedLink from './unconfirmed_link.vue'

export default {
  components: {
    'report': Report,
    'unconfirmed-link': UnconfirmedLink
  },
  data: () => {
    return {
      reports: null,
      currentPage: null,
      totalPages: null,
      currentUserId: null,
    }
  },
  created() {
    window.onpopstate = () => {
      this.currentPage = this.pageParam()
      this.getReports()
    }
    this.currentPage = this.pageParam()
    this.getReports()
  },
  methods: {
    pageParam(){
      const url = new URL(location.href)
      const page = url.searchParams.get('page')
      return parseInt(page || 1)
    },
    clickCallback(pageNum){
      this.currentPage = parseInt(pageNum)
      history.pushState(null, null, this.newURL)
      this.getReports()
    },
    getReports(){
      fetch(this.reportsAPI, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest', },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(response => {
          return response.json()
        })
        .then(json => {
          this.reports = []
          json.reports.forEach(r => { this.reports.push(r) })
          this.currentUserId = json.currentUserId
          this.totalPages = parseInt(json.totalPages)
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
  },
  computed: {
    isUncheckedReportsPage(){
      return location.pathname.includes('unchecked')
    },
    newParams(){
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      return params
    },
    newURL(){
      return `${location.pathname}?${this.newParams}`
    },
    reportsAPI(){
      const params = this.newParams
      if(this.isUncheckedReportsPage){
        return `/api/reports/unchecked.json?${params}`
      }else{
        return `/api/reports.json?${params}`
      }
    }
  }
}
</script>

<style lang="css">
.pagination__item.disabled{
  display: none;
}

.pagination__item-link{
  outline: none;
}

</style>
