<template lang="pug">
.thread-meta
  .thread-meta__watch(v-if="!watchId")
    .thread-meta__watch-button.is-inactive.a-button.is-sm.is-main.is-submit-input.is-left-icon(@click="pushWatch")
      i.fas.fa-eye
      | Watch
  .thread-meta__watch(v-else)
    .thread-meta__watch-button.is-inactive.a-button.is-sm.is-main.is-submit-input.is-left-icon(@click="pushUnWatch")
      i.fas.fa-eye
      | Unwatch

</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['watchableId', 'watchableType'],
  data () {
    return {
      watchId: null
    }
  },
  mounted () {
    fetch(`/api/${this.watchableType}s/${this.watchableId}.json`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token()
      },
      credentials: 'same-origin'
    })
    .then(response => {
      return response.json()
    })
    .then(json => {
      this.watchId = json['watch_id']
    })
    .catch(error => {
      console.warn('Failed to parsing', error)
    })
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      if (meta) {
        return meta.getAttribute('content')
      } else {
        return ''
      }
    },
    pushWatch () {
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
          this.watchId = json['watch_id']
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
    pushUnWatch () {
      fetch(`/api/watches/${this.watchId}`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
      })
        .then(response => {
          this.watchId = null
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
