<template lang="pug">
  .thread-admin-tools
    ul.thread-admin-tools__items
      li.thread-admin-tools__item
        button#js-shortcut-check.thread-check-form__action(:class=" checkId ? 'is-text' : 'a-button is-md is-danger' " @click="check")
          i.fas.fa-check
          | {{ buttonLabel }}
</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['checkableId', 'checkableType', 'checkableLabel'],
  computed: {
    checkId() {
      return this.$store.getters.checkId
    },
    buttonLabel() {
      return this.checkableLabel + (this.checkId ? 'の確認を取り消す' : 'を確認')
    },
    url() {
      return this.checkId ? `/api/checks/${this.checkId}` : '/api/checks'
    },
    method() {
      return this.checkId ? 'DELETE' : 'POST'
    }
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    check() {
      let params = {
        "checkable_type": this.checkableType,
        "checkable_id": this.checkableId
      }

      fetch(this.url, {
        method: this.method,
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
