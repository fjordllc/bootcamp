<template lang="pug">
  ul.is-button-group.practice-status__buttons
    li.practice-status__buttons-item
      button.practice-status__button.js-practice-state.a-button.is-xs(v-bind:disabled="[status === 'not_complete']" v-bind:class="[status === 'not_complete' ? 'is-primary' : 'is-secondary']")
        | 未完
    li.practice-status__buttons-item
      button.practice-status__button.js-practice-state.a-button.is-xs(v-bind:disabled="[status === 'started']" v-bind:class="[status === 'started' ? 'is-primary' : 'is-secondary']")
        | 開始
    li.practice-status__buttons-item
      button.practice-status__button.js-practice-state.a-button.is-xs(v-bind:disabled="[status === 'complete']" v-bind:class="[status === 'complete' ? 'is-primary' : 'is-secondary']")
        | 完了
</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['practiceId', 'status'],
  data () {
    return {
      isPrimary: false,
      submission: false,
      complete: false,
      product: null,
      productLabel: '',
      productLink: ''
    }
  },
  mounted () {
    console.log("status: ", this.status);
    this.status
    fetch(`/api/practices/${this.practiceId}/learning.json`, {
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
        this.submission = json['practice']['submission']
        this.complete = json['status'] == 'complete'
        this.product = json['practice']['product']
        if (this.product) {
          this.productLink = `/products/${this.product.id}`
          this.productLabel = '提出物へ'
        } else {
          this.productLink = `/products/new?practice_id=${this.practiceId}`
          this.productLabel = '提出物を作る'
        }
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
    pushComplete () {
      let params = new FormData()
      params.append('status', 'complete')

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
          this.complete = true
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
