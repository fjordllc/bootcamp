<template lang="pug">
div
  LoadingUsersPageCompanyPlaceholder(v-for='num in companyCount', :key='num')
</template>

<script>
import LoadingUsersPageCompanyPlaceholder from 'loading-users-page-company-placeholder.vue'

export default {
  components: {
    LoadingUsersPageCompanyPlaceholder: LoadingUsersPageCompanyPlaceholder
  },
  data() {
    return {
      companyCount: 9
    }
  }
}
</script>
