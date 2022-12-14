<template lang="pug">
.user-group.is-loading(v-if='!loaded')
  loadingGenerationsPageGenerationPlaceholder
.user-group(v-else-if='users.length !== 0')
  header.user-group__header
    h2.user-group__title
      a.user-group__title-link(:href='generation_url')
        span.user-group__title-label
          | {{ generation.number }}期生
        .user-group__date
          | {{ dateFormat(generation.start_date) }} ~ {{ dateFormat(generation.end_date) }}
  .a-user-icons
    .a-user-icons__items
      .a-user-icons__item(v-for='user in users', :key='user.id')
        a.a-user-icons__item-link(:href='user.url')
          img(
            :src='user.avatar_url',
            :title='user.icon_title',
            :data-login-name='user.login_name',
            :class='`a-user-icons__item-icon a-user-icon is-${user.primary_role}`')
</template>
<script>
import loadingGenerationsPageGenerationPlaceholder from './loading-generations-page-generation-placeholder.vue'

export default {
  components: {
    loadingGenerationsPageGenerationPlaceholder:
      loadingGenerationsPageGenerationPlaceholder
  },
  props: {
    generation: {
      type: Object,
      required: true
    },
    target: {
      type: String,
      required: false,
      default: 'all'
    }
  },
  data() {
    return {
      loaded: false,
      users: []
    }
  },
  computed: {
    generation_users_url() {
      return `/api/generations/${this.generation.number}/users.json?target=${this.target}`
    },
    generation_url() {
      return `/generations/${this.generation.number}`
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
      fetch(this.generation_users_url, {
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
          this.users = json.users
          this.loaded = true
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    dateFormat(date) {
      return date.replace('-', '年').replace('-', '月') + '日'
    }
  }
}
</script>
