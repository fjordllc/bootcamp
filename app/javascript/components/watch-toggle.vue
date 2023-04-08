<template lang="pug">
#watch-button.a-watch-button.a-button.is-sm.is-block(
  :class='watchId || watchableUserId ? "is-active is-main" : "is-inactive is-muted"',
  @click='buttonClick')
  | {{ watchLabel }}
</template>
<script>
import 'whatwg-fetch'
import toast from '../toast'

export default {
  name: 'WatchToggle',
  mixins: [toast],
  props: {
    watchableId: { type: Number, required: true },
    watchableType: { type: String, required: true },
    checked: { type: Boolean, required: false, default: false },
    watchIndexId: { type: Number, required: false, default: 0 }
  },
  data() {
    return {
      watchId: null,
      totalPages: 0,
      watchValue: null
    }
  },
  computed: {
    watchableUserId() {
      return this.$store.getters.watchableUserId
    },
    watchLabel() {
      if (this.checked) {
        return '削除'
      } else {
        return this.watchableUserId ? 'Watch中' : 'Watch'
      }
    }
  },
  mounted() {
    const params = new URL(location.href).searchParams
    params.set('watchable_type', this.watchableType)
    params.set('watchable_id', this.watchableId)
    if (this.checked) {
      this.watchId = this.watchIndexId
    } else {
      fetch(`/api/watches/toggle.json?${params}`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          if (json[0]) {
            this.watchId = json[0].id
            this.$store.dispatch('setWatchable', {
              watchableUserId: json[0].user_id
            })
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    buttonClick() {
      if (this.watchId) {
        this.unwatch()
      } else {
        this.watch()
      }
    },
    watch() {
      const params = {
        watchable_type: this.watchableType,
        watchable_id: this.watchableId
      }
      fetch(`/api/watches/toggle`, {
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
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.watchId = json.id
          this.toast('Watchしました！')
          this.$store.dispatch('setWatchable', {
            watchableUserId: json.user_id
          })
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    unwatch() {
      fetch(`/api/watches/toggle/${this.watchId}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(() => {
          this.watchId = null
          this.toast('Watchを外しました')
          this.$store.dispatch('setWatchable', {
            watchableUserId: null
          })
        })
        .then(() => {
          this.$emit('update-index')
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
<style scoped></style>
