<template lang="pug">
.thread-meta
  .thread-meta__watch
    .thread-meta__watch-button.a-button.is-sm.is-submit-input.is-left-icon(:class=" watchId ? 'is-active is-secondary' : 'is-inactive is-main' " @click="watch")
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
  computed: {
    url() {
      return this.watchId ? `/api/watches/${this.watchId}` : `/api/watches`
    },
    method() {
      return this.watchId ? 'DELETE' : 'POST'
    }
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    watch () {
      let params = new FormData()
      params.append(`${this.watchableType}_id`, this.watchableId)

      fetch(this.url, {
        method: this.method,
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: params
      })
        .then(response => {
          if (this.method == 'DELETE') {
            this.watchId = null
            this.watchLabel = 'Watch'
          } else {
            return response.json()
          }
        })
        .then(json => {
          if (json) {
            this.watchId = json['id']
            this.watchLabel = 'Unwatch'
          }
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
