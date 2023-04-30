<template lang="pug">
.card-list.a-card
  .card-header.is-sm
    h2.card-header__title
      | 提出物
  .card-list__items(v-if='products && products.length > 0')
    product(
      v-for='product in products',
      :key='product.id',
      :product='product',
      :current-user-id='currentUserId',
      :is-mentor='isMentor')
  .card-body(v-else)
    .card__description
      .o-empty-message
        .o-empty-message__icon
          i.fa-regular.fa-sad-tear
        .o-empty-message__text
          | 提出物はまだありません。
</template>
<script>
import Product from '../product.vue'

export default {
  name: 'UserProducts',
  components: {
    product: Product
  },
  props: {
    userId: { type: Number, default: null },
    isMentor: { type: Boolean, required: true },
    currentUserId: { type: String, required: true }
  },
  data() {
    return {
      products: null
    }
  },
  computed: {
    newParams() {
      const params = new URL(location.href).searchParams
      if (this.userId) {
        params.set('user_id', this.userId)
      }
      return params
    },
    productsAPI() {
      const params = this.newParams
      return `/api/products.json?${params}`
    }
  },
  created() {
    this.getProducts()
  },
  methods: {
    async getProducts() {
      const response = await fetch(this.productsAPI, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      }).catch((error) => console.warn(error))
      const json = await response.json().catch((error) => console.warn(error))
      this.products = json.products
    }
  }
}
</script>
