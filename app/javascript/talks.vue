<template lang="pug">
.page-body
  .container.is-md(v-if='!loaded')
    loadingListPlaceholder
  .container(v-else-if='talks.length === 0')
    | 未返信の相談部屋はありません
  .container.is-md(v-else)
    .thread-list.a-card
      talk(
        v-for='talk in talks',
        :key='talk.id',
        :user='talk.user',
        :talk='talk'
      )
</template>
<script>
import Talk from './talk.vue'
import LoadingListPlaceholder from './loading-list-placeholder.vue'
export default {
  components: {
    talk: Talk,
    loadingListPlaceholder: LoadingListPlaceholder
  },
  data() {
    return {
      talks: [],
      loaded: false
    }
  },
  computed: {
    isUnrepliedTalksPage() {
      return location.pathname.includes('unreplied')
    },
    url() {
      if (this.isUnrepliedTalksPage) {
        return `/api/talks/unreplied`
      } else {
        return `/api/talks`
      }
    }
  },
  created() {
    this.getTalks()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getTalks() {
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
          console.log(response)
          return response.json()
        })
        .then((json) => {
          this.talks = []
          json.talks.forEach((talk) => {
            this.talks.push(talk)
          })
          this.loaded = true
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
