<template lang="pug">
.thread-meta
  .thread-meta__watch
    .thread-meta__watch-button.a-button.is-sm.is-left-icon(:class=" watchId ? 'is-active is-secondary' : 'is-inactive is-main' " @click="push")
      i.fas.fa-eye
      | {{ watchLabel }}

</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['watchableId', 'watchableType'],
  data () {
    return {
      watchId: null,
      watchLabel: "Watch"
    }
  },
  mounted () {
    fetch(`/api/watches.json?${this.watchableType}_id=${this.watchableId}`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token(),
      },
      credentials: 'same-origin'
    })
    .then(response => {
      return response.json()
    })
    .then(json => {
      if (json[0]) {
        this.watchId = json[0]['id']
        this.watchLabel = 'Unwatch'
      }
    })
    .catch(error => {
      console.warn('Failed to parsing', error)
    })
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    push () {
      if (this.watchId) {
        this.unwatch()
      } else {
        this.watch()
      }
    },
    watch () {
      let params = new FormData()
      params.append(`${this.watchableType}_id`, this.watchableId)

      fetch(`/api/watches`, {
        method: 'POST',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: params
      })
        .then(response => {
          return response.json()
        })
        .then(json => {
          this.watchId = json['id']
          this.watchLabel = 'Unwatch'
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
    unwatch () {
      let params = new FormData()
      params.append(`${this.watchableType}_id`, this.watchableId)

      fetch(`/api/watches/${this.watchId}`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: params
      })
        .then(response => {
          this.watchId = null
          this.watchLabel = 'Watch'
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
<style scoped>
</style>
