<template lang="pug">
.page-body
  .container.is-lg
    .thread-list.a-card
      company(
        v-for='company in companies',
        :key='company.id',
        :company='company'
      )
</template>
<script>
import Company from './company.vue'
import UserIcon from './user-icon'

export default {
  components: {
    company: Company,
    'user-icon': UserIcon
  },
  data() {
    return {
      companies: []
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
      fetch('/api/users/companies', {
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
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
