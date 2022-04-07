<template lang="pug">
button(
  v-if='!checkerId || checkerId == currentUserId',
  :class='["a-button", "is-block", id ? "is-warning" : "is-secondary", checkableType ? "is-md" : "is-sm"]',
  @click='check'
)
  i(
    v-if='!checkerId || checkerId == currentUserId',
    :class='["fas", id ? "fa-times" : "fa-hand-paper"]',
    @click='check'
  )
  | {{ buttonLabel }}
.a-button.is-sm.is-block.thread-list-item__assignee-button.is-only-mentor(
  v-else
)
  span.thread-list-item__assignee-image
    img.a-user-icon(:src='checkerAvatar', width='20', length='20')
  span.thread-list-item__assignee-name
    | {{ this.name }}
</template>
<script>
import toast from './toast'

export default {
  mixins: [toast],
  props: {
    checkerId: { type: Number, required: false, default: null },
    checkerName: { type: String, required: false, default: null },
    currentUserId: { type: String, required: true },
    productId: { type: Number, required: true },
    checkableType: { type: String, required: false, default: null },
    checkerAvatar: { type: String, required: false, default: null }
  },
  data() {
    return {
      id: this.checkerId,
      name: this.checkerName
    }
  },
  computed: {
    buttonLabel() {
      return this.id ? '担当から外れる' : '担当する'
    },
    url() {
      return `/api/products/checker`
    }
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    check() {
      const params = {
        product_id: this.productId,
        current_user_id: this.currentUserId,
        checker_id: this.checkerId
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
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          if (json.message) {
            alert(json.message)
          } else {
            this.id = json.checker_id
            this.name = json.checker_name
            if (this.buttonLabel === '担当する') {
              this.toast('担当から外れました。')
            } else {
              this.toast('担当になりました。')
            }
          }
        })
    }
  }
}
</script>
