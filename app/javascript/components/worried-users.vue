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
          worriedUser(
            v-for='worriedUser in worriedUsers',
            :key='worriedUser.id',
            :worriedUser='worriedUser')
</template>

<script>
import CSRF from 'csrf'
import WorriedUser from './worried-user'

export default {
  name: 'WorriedUsers',
  components: {
    worriedUser: WorriedUser
  },
  data() {
    return {
      worriedUsers: [],
      loaded: false
    }
  },
  computed: {
    url() {
      return `/api/users/worried`
    }
  },
  created() {
    fetch(this.url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
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
        console.warn(error)
      })
  }
}
</script>
