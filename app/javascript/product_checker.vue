<template lang="pug">
button(
  v-if='!checkerId || checkerId === currentUserId',
  :class='["a-button", "is-block", productCheckerId ? "is-warning" : "is-secondary", checkableType ? "is-sm" : "is-sm"]',
  @click='checkInCharge')
  i(
    v-if='!checkerId || checkerId === currentUserId',
    :class='["fas", productCheckerId ? "fa-times" : "fa-hand-paper"]',
    @click='checkInCharge')
  | {{ buttonLabel }}
.a-button.is-sm.is-block.card-list-item__assignee-button.is-only-mentor(v-else)
  span.card-list-item__assignee-image
    img.a-user-icon(:src='checkerAvatar', width='20', length='20')
  span.card-list-item__assignee-name
    | {{ this.name }}
</template>
<script>
import CSRF from 'csrf'
import { toast } from 'vanillaToast'
import checkable from './checkable.js'

export default {
  mixins: [checkable],
  props: {
    checkerId: { type: Number, required: false, default: null },
    checkerName: { type: String, required: false, default: null },
    currentUserId: { type: Number, required: true },
    productId: { type: Number, required: true },
    checkableType: { type: String, required: false, default: null },
    checkerAvatar: { type: String, required: false, default: null },
    parentComponent: { type: String, required: true }
  },
  data() {
    return {
      id: this.checkerId,
      name: this.checkerName,
      parent: this.parentComponent,
      forceUpdate: false
    }
  },
  computed: {
    productCheckerId() {
      if (this.parent === 'product') {
        return this.id
      } else {
        return this.$store.getters.productCheckerId
      }
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

    window.addEventListener('checkerAssigned', this.handleCheckerAssigned)
  },
  beforeDestroy() {
    window.removeEventListener('checkerAssigned', this.handleCheckerAssigned)
  },
  methods: {
    toast(...args) {
      toast(...args)
    },
    checkInCharge() {
      this.checkProduct(
        this.productId,
        this.currentUserId,
        '/api/products/checker',
        this.productCheckerId ? 'DELETE' : 'PATCH',
        CSRF.getToken(),
        false
      )
    },
    handleCheckerAssigned() {
      this.parent = 'product'
      this.id = this.currentUserId
    }
  }
}
</script>
