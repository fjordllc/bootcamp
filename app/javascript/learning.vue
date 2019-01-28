<template lang="pug">
  .card-footer-actions
    ul.card-footer-actions__items
      li.card-footer-actions__item(v-if="submission")
        a.is-button-simple-md-primary.is-block(:href="productLink")
          i.fas.fa-file
          | {{ productLabel }}
      li.card-footer-actions__item(v-if="complete")
        button.is-button-simple-md-secondary.is-block.is-disabled
          i.fas.fa-check
          | 完了済
      li.card-footer-actions__item(v-else)
        button.is-button-simple-md-warning.is-block#js-complete(@click="pushComplete")
          i.fas.fa-check
          | 完了
</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['practiceId'],
  data () {
    return {
      submission: false,
      complete: false,
      product: null,
      productLabel: '',
      productLink: ''
    }
  },
  mounted () {
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
