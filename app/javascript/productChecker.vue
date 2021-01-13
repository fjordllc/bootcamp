<template lang="pug">
  .thread-list-item__assigned
    button(v-if="!checkerId || checkerId == currentUserId" :class="['a-button', 'is-sm', 'is-block', id ? 'is-danger' : 'is-primary']" @click="check")
      i(v-if="!checkerId || checkerId == currentUserId" :class="['fas', 'is-sm', id ? 'fa-times' : 'fa-hand-paper']" @click="check")
      | {{ buttonLabel }}
    .thread-list-item__assignee
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
      return (this.id ? this.name : "未設定")
    },
    url() {
      return `/api/products/checker`
    },
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    check() {
      let params = {
        "product_id": this.productId,
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
        if (json["message"]) {
          alert(json["message"])
        } else {
          this.id = json["checker_id"],
          this.name = json["checker_name"]
        }
      })
    }
  }
}
</script>
