<template lang="pug">
#watch-button.a-watch-button.a-button.is-sm.is-block(
  :class='watchId ? "is-active is-main" : "is-inactive is-muted"',
  @click='buttonClick')
  | {{ watchLabel }}
</template>
<script>
import 'whatwg-fetch'
import CSRF from 'csrf'
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
      totalPages: 0,
      watchValue: null
    }
  },
  computed: {
    watchId() {
      if (this.checked) {
        return this.watchIndexId
      } else {
        return this.$store.getters.watchId
      }
    },
    watchLabel() {
      if (this.checked) {
        return '削除'
      } else {
        return this.watchId ? 'Watch中' : 'Watch'
      }
    }
  },
  mounted() {
    this.$store.dispatch('setWatchable', {
      watchableId: this.watchableId,
      watchableType: this.watchableType
    })
  },
  methods: {
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
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          if (json.message) {
            this.toast(json.message, 'error')
          } else {
            this.toast('Watchしました！')
            this.$store.dispatch('setWatchable', {
              watchableId: json.watchable_id,
              watchableType: json.watchable_type
            })
          }
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
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(() => {
          this.toast('Watchを外しました')
          this.$store.dispatch('setWatchable', {
            watchableId: this.watchableId,
            watchableType: this.watchableType
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
