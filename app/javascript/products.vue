<template lang="pug">
  .page-body
    .container
      .thread-list.a-card(v-if="products.length > 0")
        product(v-for="(product, index) in products"
          :key="product.id"
          :product="product")
        .thread-admin-tools(v-if="mentorLogin && selectedTab != 'all'")
          ul.thread-admin-tools__items
            li.thread-admin-tools__item
              button#js-shortcut-unconfirmed-links-open.thread-unconfirmed-links-form__action(class="a-button is-md is-primary")
                | {{ unconfirmedLinksName }}の提出物を一括で開く
      .o-empty-massage(v-else)
        .o-empty-massage__icon
          i.far.fa-smile
        p.o-empty-massage__text
          | {{ title }}はありません
</template>

<script>
import Product from './product.vue'

export default {
  props: ['title', 'selectedTab', 'mentorLogin'],
  components: {
    'product': Product
  },
  data: () => {
    return {
      products: [],
    }
  },
  computed: {
    url () {
      switch (this.selectedTab) {
      case 'all':
        return '/api/products'
      case 'unchecked':
        return '/api/products/unchecked'
      case 'not-responded':
        return '/api/products/not_responded'
      case 'self-assigned':
        return '/api/products/self_assigned'
      }
    },
    unconfirmedLinksName() {
      if (this.selectedTab == 'unchecked') {
        return '未チェック'
      } else if (this.selectedTab == 'not-responded') {
        return '未返信'
      } else if (this.selectedTab == 'self-assigned') {
        return '自分の担当'
      }
    }
  },
  created () {
    this.products = []
    fetch(this.url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token()
      },
      credentials: 'same-origin',
      redirect: 'manual',
    })
    .then(response => {
      return response.json();
    })
    .then(json => {
      json.products.forEach(c => {
        this.products.push(c);
      });
    })
    .catch(error => {
      console.warn('Failed to parsing', error)
    })
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
  }
}
</script>
