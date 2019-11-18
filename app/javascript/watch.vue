<template lang="pug">
.thread-header__watch
  .thread-header__watch-button.a-button.is-sm.is-left-icon(:class=" watchId ? 'is-active is-secondary' : 'is-inactive is-main' " @click="push")
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
      watchLabel: "Watchする"
    }
  },
  mounted () {
    fetch(`/api/watches.json?watchable_type=${this.watchableType}&watchable_id=${this.watchableId}`, {
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
        this.watchLabel = 'Watch中'
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
      let params = {
        'watchable_type': this.watchableType,
        'watchable_id': this.watchableId
      }

      fetch(`/api/watches`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then(response => {
          return response.json()
        })
        .then(json => {
          this.watchId = json['id']
          this.watchLabel = 'Watch中'
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
    unwatch () {
      fetch(`/api/watches/${this.watchId}`, {
        method: 'DELETE',
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(response => {
          this.watchId = null
          this.watchLabel = 'Watchする'
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
