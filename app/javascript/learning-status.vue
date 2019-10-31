<template lang="pug">
  ul.is-button-group.practice-status__buttons
    li.practice-status__buttons-item
      button.practice-status__button.a-button.is-xs.js-not-complete(v-bind:disabled="statusName === 'not_complete'" v-bind:class="[statusName === 'not_complete' ? 'is-primary' : 'is-secondary']" @click="pushStatus('not_complete')")
        | 未着手
    li.practice-status__buttons-item
      button.practice-status__button.a-button.is-xs.js-started(v-bind:disabled="statusName === 'started'" v-bind:class="[statusName === 'started' ? 'is-primary' : 'is-secondary']" @click="pushStatus('started')")
        | 着手
    li.practice-status__buttons-item
      button.practice-status__button.a-button.is-xs.js-submitted(v-bind:disabled="statusName === 'submitted'" v-bind:class="[statusName === 'submitted' ? 'is-primary' : 'is-secondary']" @click="pushStatus('submitted')")
        | 提出
    li.practice-status__buttons-item
      button.practice-status__button.a-button.is-xs.js-complete(v-bind:disabled="statusName === 'complete'" v-bind:class="[statusName === 'complete' ? 'is-primary' : 'is-secondary']" @click="pushStatus('complete')")
        | 完了
</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['practiceId', 'status'],
  data () {
    return {
      statusName: null
    }
  },
  mounted () {
    this.statusName = this.status
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    pushStatus (name) {
      let params = new FormData()
      params.append('status', name)

      fetch(`/api/practices/${this.practiceId}/learning.json`, {
        method: 'PATCH',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: params
      })
        .then(response => {
          this.statusName = name
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
  }
}
</script>
<style scoped>
</style>
