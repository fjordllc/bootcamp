<template lang="pug">
  .thread-list-item-meta__item
    button.thread-check-form__action(v-if="!checkerId || checkerId == currentUserId" :class=" id ? 'a-button is-md is-danger' : 'a-button is-md is-primary'" @click="check")
      i.fas.fa-hand-paper
      | {{ buttonLabel }}
    .thread-list-item-meta__label
      | {{ checkerLabel }}
</template>
<script>
export default {
  props: ['checkerId', 'checkerName', 'currentUserId', 'productId'],
  data () {
    return {
      id: this.checkerId,
      name: this.checkerName,
    }
  },
  computed: {
    buttonLabel() {
      return this.id ? "担当から外れる" : "私が見ます"
    },
    checkerLabel() {
      return '担当者：' + (this.id ? this.name : "未設定")
    },
    url() {
      return `/api/products/${this.productId}/checker`
    },
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    check() {
      let params = {
        "current_user_id": this.currentUserId,
        "checker_id": this.checkerId
      }
      fetch(this.url, {
        method: 'PATCH',
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
        return response.json()
      })
      .then(json => {
        if (json["errorMessage"]) {
          alert(json["errorMessage"])
        } else {
          this.id = json["checker_id"],
          this.name = json["checker_name"]
        }
      })
    }
  }
}
</script>
