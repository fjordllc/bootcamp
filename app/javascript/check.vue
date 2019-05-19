<template lang="pug">
  .thread-admin-tools
    ul.thread-admin-tools__items#js-checked
      li.thread-admin-tools__item(v-if="!checkId")
        button.thread-check-form__action.a-button.is-md.is-danger(@click="pushCheck")
          i.fas.fa-check
          | {{checkButtonLabel()}}
      li.thread-admin-tools__item(v-else)
        button.thread-check-form__action.is-text(@click="pushUnCheck")
          i.fas.fa-check
          | {{checkableLabel}}の確認を取り消す
</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['checkableId', 'checkableType', 'checkableLabel'],
  data () {
    return {
      checkId: null
    }
  },
  mounted () {
    fetch(`/api/${this.checkableType}s/${this.checkableId}.json`, {
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
      this.checkId = json['check_id']
    })
    .catch(error => {
      console.warn('Failed to parsing', error)
    })
  },
  methods: {
    checkButtonLabel() {
      if (this.checkableType == 'product') {
        return '提出物を確認'
      } else if (this.checkableType == 'report') {
        return '日報を確認する'
      }
    },
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      if (meta) {
        return meta.getAttribute('content')
      } else {
        return ''
      }
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
          return response.json()
        })
        .then(json => {
          this.checkId = json['check_id']
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
          this.checkId = null
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
