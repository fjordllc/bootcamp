<template lang="pug">
  .practice-content-actions
    ul.practice-content-actions__items
      div(v-if="submission")
        li.practice-content-actions__item
          a.is-button-simple-md-primary(:href="productLink")
            i.fas.fa-file
            | {{ productLabel }}
      div(v-if="!complete")
        li.practice-content-actions__item
          button.is-button-simple-md-warning#js-complete(@click="pushComplete")
            i.fas.fa-check
            | 完了
</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['practiceId'],
  data: () => {
    return {
      toke: null,
      submission: false,
      complete: false,
      product: null,
      productLabel: '',
      productLink: ''
    }
  },
  mounted: function () {
    this.token = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')

    fetch(`/api/practices/${this.practiceId}/learning.json`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token
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
          this.productLink = `/practices/${this.practiceId}/products/${
            this.product.id
          }`
          this.productLabel = '提出物'
        } else {
          this.productLink = `/practices/${this.practiceId}/products/new`
          this.productLabel = '提出物を作る'
        }
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
  },
  methods: {
    pushComplete: function () {
      let params = new FormData()
      params.append('status', 'complete')

      fetch(`/api/practices/${this.practiceId}/learning.json`, {
        method: 'PATCH',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token
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
