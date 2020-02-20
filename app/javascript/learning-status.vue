<template lang="pug">
  .practice-status-buttons
    ul.practice-status-buttons__items.is-button-group
      li.practice-status-buttons__item
        button.practice-status-buttons__button.a-button.is-md.is-block.is-not_complete.js-not-complete(v-bind:disabled="statusName === 'not_complete'" v-bind:class="[statusName === 'not_complete' ? 'is-active' : 'is-inactive']" @click="pushStatus('not_complete')")
          | 未着手
      li.practice-status-buttons__item
        button.practice-status-buttons__button.a-button.is-md.is-block.is-started.js-started(v-bind:disabled="statusName === 'started'" v-bind:class="[statusName === 'started' ? 'is-active' : 'is-inactive']" @click="pushStatus('started')")
          | 着手
      li.practice-status-buttons__item
        button.practice-status-buttons__button.a-button.is-md.is-block.is-submitted.js-submitted(v-bind:disabled="statusName === 'submitted'" v-bind:class="[statusName === 'submitted' ? 'is-active' : 'is-inactive']" @click="pushStatus('submitted')")
          | 提出
      li.practice-status-buttons__item
        button.practice-status-buttons__button.a-button.is-md.is-block.is-complete.js-complete(v-bind:disabled="statusName === 'complete'" v-bind:class="[statusName === 'complete' ? 'is-active' : 'is-inactive']" @click="pushStatus('complete')")
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
          if(response.ok) {
            this.statusName = name
            return this
          }else{
            response.json().then(data => {
              alert(data.error)
            });
          }
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
