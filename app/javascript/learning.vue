<template lang="pug">
.card-main-actions
  ul.card-main-actions__items
    li.card-main-actions__item(v-if='submission')
      a.a-button.is-sm.is-primary.is-block.test-product(:href='productLink')
        i.fa-solid.fa-file
        | {{ productLabel }}
    li.card-main-actions__item(v-if='complete')
      button.a-button.is-sm.is-secondary.is-block.is-disabled.test-completed
        i.fa-solid.fa-check
        | 修了しています
    li.card-main-actions__item(v-else)
      label#js-complete.a-button.is-sm.is-warning.is-block(
        @click='pushComplete',
        for='modal-learning_completion')
        i.fa-solid.fa-check
        | 修了
</template>
<script>
import 'whatwg-fetch'
import CSRF from 'csrf'

export default {
  props: {
    practiceId: { type: String, required: true }
  },
  data() {
    return {
      submission: false,
      complete: false,
      product: null,
      productLabel: '',
      productLink: ''
    }
  },
  mounted() {
    fetch(`/api/practices/${this.practiceId}/learning.json`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin'
    })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        this.submission = json.practice.submission
        this.complete = json.status === 'complete'
        this.product = json.practice.product
        if (this.product) {
          this.productLink = `/products/${this.product.id}`
          this.productLabel = '提出物へ'
        } else {
          this.productLink = `/products/new?practice_id=${this.practiceId}`
          this.productLabel = '提出物を作る'
        }
      })
      .catch((error) => {
        console.warn(error)
      })
  },
  methods: {
    pushComplete() {
      const params = new FormData()
      params.append('status', 'complete')

      fetch(`/api/practices/${this.practiceId}/learning.json`, {
        method: 'PATCH',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: params
      })
        .then(() => {
          this.complete = true
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
<style scoped></style>
