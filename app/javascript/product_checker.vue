<template lang="pug">
button(
  v-if='!checkerId || checkerId == currentUserId',
  :class='["a-button", "is-block", id ? "is-warning" : "is-secondary", checkableType ? "is-sm" : "is-sm"]',
  @click='checkInCharge'
)
  i(
    v-if='!checkerId || checkerId == currentUserId',
    :class='["fas", productCheckerId ? "fa-times" : "fa-hand-paper"]',
    @click='checkInCharge'
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
<<<<<<< HEAD
import toast from 'toast'
=======
import toast from './toast'
import checkable from './checkable.js'
>>>>>>> a9d264089 (Vuexを使って実装)

export default {
  mixins: [toast, checkable],
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
      name: this.checkerName
    }
  },
  computed: {
    productCheckerId() {
      return this.$store.getters.productCheckerId
    },
    buttonLabel() {
      return this.productCheckerId ? '担当から外れる' : '担当する'
    },
    url() {
      return `/api/products/checker`
    }
  },
  mounted() {
    this.$store.dispatch('setProduct', {
      productId: this.productId
    })
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    checkInCharge() {
      this.checker(
        this.productId,
        this.currentUserId,
        '/api/products/checker',
        'PATCH',
        this.token()
      )
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
