<template lang="pug">
.page-body
  .container(v-if='!loaded')
    | ロード中
  .container.is-md(v-else)
    .admin-table
      table.admin-table__table
        thead.admin-table__header
          tr.admin-table__labels
            th.admin-table__label
              | ユーザー
            th.admin-table__label
              | ID
            th.admin-table__label
              | 進捗
        tbody.admin-table__items
          worriedUsers(
            v-for='worriedUser in worriedUsers',
            :key='worriedUser.id',
            :worriedUser='worriedUser'
          )
</template>

<script>
import WorriedUsers from './worried-user.vue'

export default {
  components: {
    worriedUsers: WorriedUsers
  },
  data() {
    return {
      worriedUsers: [],
      loaded: false
    }
  },
  computed: {
    url() {
      return `/api/mentor`
    }
  },
  created() {
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
        this.worriedUsers = json.worried_users
        this.loaded = true
      })
      .catch((error) => {
        console.warn('Failed to parsing', error)
      })
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    }
  }
}
</script>
