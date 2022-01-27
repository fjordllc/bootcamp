<template lang="pug">
.container.is-padding-horizontal-0-sm-down
  nav.pagination(v-if='totalPages > 1')
    pager(v-bind='pagerProps')
  .admin-table
    table.admin-table__table
      thead.admin-table__header
        tr.admin-table__labels
          th.admin-table__label
            | 名前
          th.admin-table__label
            | ロゴ
          th.admin-table__label
            | ウェブサイト
          th.admin-table__label.actions
            | リンク
          th.admin-table__label.actions
            | 操作
      tbody.admin-table__items
        tr.admin-table__item(
          v-for='company in companies',
          :key='company.id',
          :id='`company_${company.id}`',
          v-if='companies'
        )
          td.admin-table__item-value
            | {{ company.name }}
          td.admin-table__item-value.is-text-align-center
            img.admin-table__item-logo-image(
              v-if='company.logo_url',
              :src='company.logo_url'
            )
          td.admin-table__item-value
            | {{ company.website }}
          td.admin-table__item-value.is-text-align-center
            a.a-button.is-sm.is-secondary.is-icon(
              :title='"アドバイザーサインアップURL"',
              :href='company.adviser_sign_up_url'
            )
              i.fas.fa-user-plus
          td.admin-table__item-value.is-text-align-center
            ul.is-inline-buttons
              li
                a.a-button.is-sm.is-secondary.is-icon(
                  :href='`/admin/companies/${company.id}/edit`'
                )
                  i.fas.fa-pen
              li
                a.a-button.is-sm.is-danger.is-icon.js-delete(
                  @click='destroy(company)'
                )
                  i.fas.fa-trash-alt
    nav.pagination(v-if='totalPages > 1')
      pager(v-bind='pagerProps')
</template>

<script>
import Pager from './pager'
import toast from './toast'

export default {
  components: {
    pager: Pager
  },
  mixins: [toast],
  data() {
    return {
      companies: [],
      totalPages: 0,
      currentPage: this.getCurrentPage(),
      loaded: false
    }
  },
  computed: {
    url() {
      return `/api/admin/companies?page=${this.currentPage}`
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
    window.onpopstate = () => {
      this.currentPage = this.getCurrentPage()
      this.getCompaniesPage()
    }
    this.getCompaniesPage()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getCompaniesPage() {
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
        .then((response) => response.json())
        .then((json) => {
          this.companies = json.companies
          this.totalPages = json.total_pages
          this.loaded = true
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    destroy(company) {
      if (window.confirm('本当によろしいですか？')) {
        fetch(`/api/admin/companies/${company.id}.json`, {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual'
        })
          .then((response) => {
            if (response.ok) {
              // eslint-disable-next-line vue/no-mutating-props
              this.companies = this.companies.filter((v) => v.id !== company.id)
              this.toast('企業を削除しました。')
            } else {
              alert('削除に失敗しました')
            }
          })
          .catch((error) => {
            console.warn(error)
          })
      }
    },
    getCurrentPage() {
      const params = new URLSearchParams(location.search)
      const page = params.get('page')
      return parseInt(page) || 1
    },
    paginateClickCallback(pageNumber) {
      this.currentPage = pageNumber
      this.getCompaniesPage()

      const url = new URL(location.href)
      if (pageNumber === 1) {
        url.searchParams.delete('page')
      } else {
        url.searchParams.set('page', pageNumber)
      }
      history.pushState(history.state, '', url)
    }
  }
}
</script>
