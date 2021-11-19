<template lang="pug">
#featured-entry-button.a-featured-entry-button.a-button.is-xs.is-block(
  :class='featuredEntryId ? "is-active is-main" : "is-inactive is-muted"',
  @click='push'
)
  | {{ featuredEntryLabel }}
</template>

<script>
import toast from './toast'

export default {
  mixins: [toast],
  props: {
    featureableId: { type: Number, required: true },
    featureableType: { type: String, required: true },
    featuredEntryIndexId: { type: Number, required: false, default: 0 }
  },
  data() {
    return {
      featuredEntryId: null,
      featuredEntryLabel: '☆'
    }
  },
  created() {
    this.getFeaturedEntry()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    push() {
      if (this.featuredEntryId) {
        this.unfeature()
      } else {
        this.feature()
      }
    },
    getFeaturedEntry() {
      fetch(
        `/api/featured_entries.json?featureable_type=${this.featureableType}&featureable_id=${this.featureableId}`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual'
        }
      )
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          if (json.featuredEntries.length) {
            this.featuredEntryId = json.featuredEntries[0].id
            this.featuredEntryLabel = '⭐︎'
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    feature() {
      fetch(
        `/api/featured_entries.json?featureable_type=${this.featureableType}&featureable_id=${this.featureableId}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual'
        }
      )
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.featuredEntryId = json.id
          this.featuredEntryLabel = '⭐︎'
          this.toast('注目エントリーを登録しました！')
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    unfeature() {
      fetch(`/api/featured_entries/${this.featuredEntryId}`, {
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
          this.featuredEntryId = null
          this.featuredEntryLabel = '☆'
          this.toast('注目エントリーを削除しました')
        })
        .then(() => {
          this.$emit('update-index')
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>

<style scoped></style>
