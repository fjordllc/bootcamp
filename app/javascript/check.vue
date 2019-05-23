<template lang="pug">
  .thread-admin-tools
    ul.thread-admin-tools__items
      li.thread-admin-tools__item(v-if="!checkId")
        button.thread-check-form__action.a-button.is-md.is-danger(@click="pushCheck")
          i.fas.fa-check
          | {{checkableLabel}}を確認
      li.thread-admin-tools__item(v-else)
        button.thread-check-form__action.is-text(@click="pushUnCheck")
          i.fas.fa-check
          | {{checkableLabel}}の確認を取り消す
</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['checkableId', 'checkableType', 'checkableLabel'],
  computed: {
    checkId() {
      return this.$store.getters.checkId
    },
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    pushCheck () {
      let params = new FormData()
      params.append(`${this.checkableType}_id`, this.checkableId)

      fetch(`/api/checks`, {
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
          this.$store.dispatch('setCheckable', {
            checkableId: this.checkableId,
            checkableType: this.checkableType
          })
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
    pushUnCheck () {
      fetch(`/api/checks/${this.checkId}`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
      })
        .then(response => {
          this.$store.dispatch('setCheckable', {
            checkableId: this.checkableId,
            checkableType: this.checkableType
          })
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
