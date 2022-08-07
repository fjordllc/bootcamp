<template lang="pug">
div
  loadingUsersPageCompanyPlaceholder(v-for='num in companyCount', :key='num')
</template>

<script>
import LoadingUsersPageCompanyPlaceholder from 'loading-users-page-company-placeholder.vue'

export default {
  components: {
    loadingUsersPageCompanyPlaceholder: LoadingUsersPageCompanyPlaceholder
  },
  data() {
    return {
      companyCount: 9
    }
  }
}
</script>
