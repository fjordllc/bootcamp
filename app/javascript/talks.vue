<template lang="pug">
.page-body
  .container.is-md
    .thread-list.a-card
      talk(v-for='user in users', :key='user.id', :user='user')
</template>

<script>
import Talk from './talk.vue'
export default {
  components: {
    talk: Talk
  },
  data() {
    return {
      users: []
    }
  },
  computed: {
    url() {
      return `/api/users`
    }
  },
  created() {
    this.getUsers()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getUsers() {
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
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          console.log(json)
          this.users = []
          json.users.forEach((user) => {
            this.users.push(user)
          })
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
