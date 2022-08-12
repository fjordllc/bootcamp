<template lang="pug">
.page-body
  .container.is-lg
    .card-list.a-card.is-loading(v-if='!loaded')
      loadingUsersPageCompaniesPlaceholder
    .card-list.a-card(v-else)
      company(
        v-for='company in companies',
        :key='company.id',
        :company='company'
      )
</template>
<script>
import Company from 'company.vue'
import LoadingUsersPageCompaniesPlaceholder from 'loading-users-page-companies-placeholder.vue'

export default {
  components: {
    company: Company,
    loadingUsersPageCompaniesPlaceholder: LoadingUsersPageCompaniesPlaceholder
  },
  props: {
    target: {
      type: String,
      required: false,
      default: 'all'
    }
  },
  data() {
    return {
      companies: [],
      loaded: false
    }
  },
  computed: {
    url() {
      return `/api/users/companies?target=${this.target}`
    }
  },
  created() {
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
          this.companies = json
          this.loaded = true
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
