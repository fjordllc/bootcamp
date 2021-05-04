<template lang="pug">
.page-body
  //- = paginate @users, position: 'top'
  .container
    .users
      .row.is-gutter-width-32(v-if='this.users.length === 0')
        .o-empty-message
          .o-empty-message__icon
            i.far.fa-sad-tear
          p.o-empty-message__text 
            | {{ targetName }}のユーザーはいません
      .row.is-gutter-width-32(v-else)
        user(
          v-for='user in users',
          :key='user.id',
          :user='user',
          :currentUser='currentUser'
        )
  //- = paginate @users, position: 'bottom'
</template>
<script>
import User from './user.vue'

export default {
  components: {
    user: User
  },
  data() {
    return {
      users: [],
      pathname: location.pathname,
      currentUser: null,
      currentTarget: null,
      currentTag: null
    }
  },
  computed: {
    targetName() {
      return this.currentTag || this.currentTarget
    },
    params() {
      const params = {}
      location.search.slice(1).split('&').forEach(query => {
        const queryArr = query.split('=')
        params[queryArr[0]] = queryArr[1]
      })
      return params
    },
    url() {
      if (location.pathname.match(/tags/)) {
        return '/api' + location.pathname
      } else {
        return '/api/users/' + `?target=${this.params.target}`
      }
    }
  },
  created() {
    this.getUsers()
  },
  methods: {
    getUsers() {
      fetch(this.url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          // 'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.users = []
          json.users.forEach((user) => {
            this.users.push(user)
          })
          this.currentUser = json.currentUser
          this.currentTarget = json.target
          this.currentTag = json.tag
        })
    },
    
  }
}
</script>

